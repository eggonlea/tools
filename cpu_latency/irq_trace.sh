set -x

adb shell "echo 20000 > /d/tracing/buffer_size_kb"
adb shell "echo 1 > /d/tracing/events/irq/enable"
adb shell "echo 1 > d/tracing/tracing_on"

read -p "collecting..."

adb shell "echo 0 > /d/tracing/events/irq/enable"
adb shell "echo 0 > d/tracing/tracing_on"
adb pull /d/tracing/trace .

cat trace | grep "\[000\]" | grep "irq_handler" > cpu0irqs
