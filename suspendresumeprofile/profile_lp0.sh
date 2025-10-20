set -x

mkdir -p out

adb wait-for-device

# interactivce mode is DISABLED by default
INTER=${2:-0}

# async suspend/resume is ENABLED by default
ASYNC=${1:-1}
adb shell "echo ${ASYNC} > /sys/power/pm_async"

EVENTS="\
power/cpu_suspend \
power/machine_suspend \
display/display_disable \
display/display_enable \
display/display_mode \
display/display_reset \
display/display_suspend \
display/display_resume \
printk \
power/cpu_hotplug \
sched \
events/irq \
power \
"

OLDPRINTK=`adb shell cat /proc/sys/kernel/printk`
adb shell "echo '0 0 0 0' > /proc/sys/kernel/printk"
adb shell dmesg -c
#adb shell "echo 0 > /d/tracing/tracing_on"
adb shell "echo global > /d/tracing/trace_clock"
adb shell "echo nop > /d/tracing/current_tracer"
adb shell "echo 1 > /d/tracing/free_buffer"
adb shell "echo 10240 > /d/tracing/buffer_size_kb"
#adb shell "echo function > /d/tracing/current_tracer"
adb shell "echo nooverwrite > /d/tracing/trace_options"

echo "Start tracing..."
#FIXME: disable USB OTG wakelock and NETLINK wakeup
otg_wakelock.sh 0
adb shell "echo 1 > /d/tracing/tracing_on"
for EVENT in ${EVENTS}; do
	adb shell "echo 1 > /d/tracing/events/${EVENT}/enable"
done
adb shell "echo '=== START SUSPEND RESUME PROFILING ===' > /d/tracing/trace_marker"

echo "1. Disconnect USB"
#pm342 usb_off
sleep 1

echo "2. Press power key to sleep"
echo "3. Press power key to resume"
if [ ${INTER} -eq 0 ]; then
	#pm342 onkey
	adb shell input keyevent KEYCODE_POWER
	echo "Sleep 3s..."
	sleep 3

	pm342 onkey
	echo "Sleep 3s..."
	sleep 3
else
	echo "After the above is done, press <ENTER> to continue..."
	read
fi

echo "4. Connect USB"
#pm342 usb_on

echo "Waiting for adb..."
adb wait-for-device

echo "Stop tracing..."
adb shell "echo '=== STOP SUSPEND RESUME PROFILING ===' > /d/tracing/trace_marker"
for EVENT in ${EVENTS}; do
	adb shell "echo 0 > /d/tracing/events/${EVENT}/enable"
done
adb shell "echo 0 > /d/tracing/tracing_on"
adb shell "echo '${OLDPRINTK}' > /proc/sys/kernel/printk"
otg_wakelock.sh 1

adb shell "cat /d/tracing/trace > /data/trace.log"
adb shell "dmesg > /data/dmesg.log"

echo "Pull /data/trace.log --> out/trace_async${ASYNC}.log"
adb pull /data/trace.log out/trace_async${ASYNC}.log
echo "Pull /data/dmesg.log --> out/dmesg_async${ASYNC}.log"
adb pull /data/dmesg.log out/dmesg_async${ASYNC}.log

echo -n "dummy-0 [000] .... 0.0: tracing_mark_write: mode=" >> out/trace_async${ASYNC}.log
adb shell "cat /sys/power/suspend/mode" >> out/trace_async${ASYNC}.log
echo -n "dummy-0 [000] .... 0.0: tracing_mark_write: suspend_time=" >> out/trace_async${ASYNC}.log
adb shell "cat /sys/power/suspend/suspend_time" >> out/trace_async${ASYNC}.log
echo -n "dummy-0 [000] .... 0.0: tracing_mark_write: resume_time=" >> out/trace_async${ASYNC}.log
adb shell "cat /sys/power/suspend/resume_time" >> out/trace_async${ASYNC}.log

ls -alh out/trace_async${ASYNC}.log out/dmesg_async${ASYNC}.log

