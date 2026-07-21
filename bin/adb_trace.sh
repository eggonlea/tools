#!bin/bash

#start tracing
s()
{
    # disable tracing and clear trace ring-buffer
    adb shell "echo 0 > /d/tracing/tracing_on"
    adb shell "echo   > /d/tracing/trace"
    adb shell "echo 200000 > /d/tracing/buffer_total_size_kb"
    adb shell "echo 50000 > /d/tracing/buffer_size_kb"

    # remove any older trace.out file
    adb shell "rm -f /data/trace.out"

    # Enable ftrace events. trace_printk() will show up automatically
    adb shell "echo 1 > /d/tracing/events/sched/enable"
    adb shell "echo 1 > /d/tracing/events/power/enable"
    adb shell "echo 1 > /d/tracing/events/timer/enable"
    adb shell "echo 1 > /d/tracing/events/irq/enable"
    adb shell "echo 1 > /d/tracing/events/cpufreq_interactive/enable"

    #adb shell "echo 1 > /d/tracing/events/irq/enable"
    adb shell "echo 1 > /d/tracing/tracing_on"
    echo "Started tracing."
}

# stop tracing
p()
{
    adb shell "echo 0 > /d/tracing/tracing_on"
    echo -n "Stopped tracing. Collecting data..."
    adb shell "cat /d/tracing/trace > /data/trace.out"
    adb pull /data/trace.out $1.out
    echo "File at: $1.out"
    echo "Done."
}

if [ $1 == 's' ]; then
	s
else
	if [ $1 == 'p' ]; then
		p $2
	else
		echo "usage: $0 [s]tart|sto[p]"
	fi
fi
