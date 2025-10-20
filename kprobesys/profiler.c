/*
 * profiler.c
 *
 * Here's a simple kernel module reporting the average execution time
 * time for probed functions.
 *
 * usage: insmod profiler.ko funcs=<func_name[,...]>
 *
 * If no func_name is specified, the module just does nothing.
 *
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/device.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/kprobes.h>
#include <linux/ktime.h>
#include <linux/limits.h>
#include <linux/sched.h>
#include <linux/string.h>

/* One page can hold 128 entries of 32-byte strings */
#define	MAX_FUNCS	128
#define	CLASS_NAME	"kprobesys"
#define	DEVICE_NAME	"profiler"

/* Module parameters */
static unsigned int func_num;
static char *funcs[MAX_FUNCS];
static s64 duration[MAX_FUNCS];
static int count[MAX_FUNCS];
module_param_array(funcs, charp, &func_num, 0);
MODULE_PARM_DESC(funcs, "Function list to be profiled");

/* Variables for sysfs node */
static dev_t profiler_dev;
static struct class *profiler_class;
static struct device *profiler_device;

/* per-instance private data */
struct profiler_data {
	ktime_t entry_stamp;
};

/* TODO: allocate hook arrays dynamically to save memory */
static struct kretprobe rps[MAX_FUNCS];

/* Calculate and show average execution time */
static ssize_t stat_show(struct kobject *kobj, struct kobj_attribute *attr,
		char *buf)
{
	s64 avg;
	int i;
	int len = 0;
	for (i=0; i<func_num; i++) {
		if (funcs[i] == NULL)
			continue;

		avg = duration[i];
		if (count[i] > 0)
			do_div(avg, count[i]);
		len += scnprintf(buf + len, PAGE_SIZE, "%s:%lld:%d\n",
				funcs[i], avg, count[i]);
	}

	return len;
}

static struct kobj_attribute stat_attr = __ATTR_RO(stat);

/* Record the entry timestamp */
static int entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	struct profiler_data *data;

	data = (struct profiler_data *)ri->data;
	data->entry_stamp = ktime_get();
	return 0;
}

/* Record the duration return handler */
static int ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	struct profiler_data *data = (struct profiler_data *)ri->data;
	s64 delta;
	ktime_t now;
	int i;

	now = ktime_get();
	delta = ktime_to_ns(ktime_sub(now, data->entry_stamp));
	for (i=0; i<func_num; i++) {
		if (rps[i].kp.addr == ri->rp->kp.addr) {
			duration[i] += delta;
			count[i] ++;
			break;
		}
	}

	return 0;
}

static int __init profiler_init(void)
{
	int i;
	int ret = 0;
	int installed = 0;
	int failed = 0;

	/* Nothing to do? */
	if (func_num <= 0) {
		printk(KERN_INFO "No function list provided, exit\n");
		return -EINVAL;
	}

	/* Create sysfs paths */
	ret = alloc_chrdev_region(&profiler_dev, 0, 1, DEVICE_NAME);
	if (ret < 0) {
		printk(KERN_ERR "Failed to alloc device\n");
		goto fail_alloc;
	}

	profiler_class = class_create(THIS_MODULE, CLASS_NAME);
	if (IS_ERR(profiler_class)) {
		ret = PTR_ERR(profiler_class);
		printk(KERN_ERR "Failed to create class: %d\n", ret);
		goto fail_class;
	}

	profiler_device = device_create(profiler_class, NULL,
			profiler_dev, NULL, DEVICE_NAME);
	if (IS_ERR(profiler_device)) {
		ret = PTR_ERR(profiler_device);
		printk(KERN_ERR "Failed to create device: %d\n", ret);
		goto fail_device;
	}

	ret = sysfs_create_file(&profiler_device->kobj, &stat_attr.attr);
	if (ret) {
		printk(KERN_ERR "Failed to create sysfs node\n");
		goto fail_attr;
	}

	/* Set up probes */
	for (i=0; i<func_num; i++) {
		rps[i].handler		= ret_handler;
		rps[i].entry_handler	= entry_handler;
		rps[i].data_size	= sizeof(struct profiler_data);
		rps[i].kp.symbol_name 	= funcs[i];
		ret = register_kretprobe(&rps[i]);
		if (ret < 0) {
			printk(KERN_WARNING "Failed to hook [%s]: %d\n",
					funcs[i], ret);
			/* Mark it as invalid */
			funcs[i] = NULL;
			failed++;
		} else {
			printk(KERN_INFO "New profiler %s at %p\n",
					rps[i].kp.symbol_name,
					rps[i].kp.addr);
			installed++;
		}
	}
	printk(KERN_INFO "Totally functions: %d (%d installed, %d failed)\n",
			func_num, installed, failed);

	return 0;

fail_attr:
	device_destroy(profiler_class, profiler_dev);
fail_device:
	class_destroy(profiler_class);
fail_class:
	unregister_chrdev_region(profiler_dev, 1);
fail_alloc:
	return ret;
}

static void __exit profiler_exit(void)
{
	int i;
	for (i=0; i<func_num; i++) {
		if (funcs[i] == NULL)
			continue;

		unregister_kretprobe(&rps[i]);
		if (rps[i].nmissed > 0)
			printk(KERN_INFO "%s (%p) missed %d times\n",
					rps[i].kp.symbol_name,
					rps[i].kp.addr,
					rps[i].nmissed);
	}

	sysfs_remove_file(&profiler_device->kobj, &stat_attr.attr);
	device_destroy(profiler_class, profiler_dev);
	class_destroy(profiler_class);
	unregister_chrdev_region(profiler_dev, 1);
	printk(KERN_INFO "Profiler exit\n");
}

module_init(profiler_init)
module_exit(profiler_exit)
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Li Li");
