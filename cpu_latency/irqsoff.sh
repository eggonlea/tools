set -x

EVENTS="sched idle irq workqueue timer sys_calls migrate lowmemorykiller zram_drv cpufreq_interactive"
#EVENTS="cpufreq_interactive"

adb shell "echo 51200 > /d/tracing/buffer_size_kb"

for i in ${EVENTS}
do
	adb shell "echo 1 > /d/tracing/events/$i/enable"
done
adb shell "echo irqsoff > /d/tracing/current_tracer"
adb shell "echo 1 > /d/tracing/tracing_on"

adb shell cat /d/tracing/trace_pipe > trace_pipe &
read -p "collecting..."
adb pull /d/tracing/trace .

adb shell "echo 0 > /d/tracing/tracing_on"
adb shell "echo nop > /d/tracing/current_tracer"
for i in ${EVENTS}
do
	adb shell "echo 0 > /d/tracing/events/$i/enable"
done

cat ./trace
