#!bin/bash

adb shell "rm /sdcard/ftrace.log"
adb shell "echo '##### Before tracing_off' > /sys/kernel/debug/tracing/trace_marker"
adb shell "echo 0 > /sys/kernel/debug/tracing/tracing_on"
adb shell "echo '##### After tracing_off' > /sys/kernel/debug/tracing/trace_marker"
adb shell "cat /sys/kernel/debug/tracing/trace > /sdcard/ftrace.log"
adb shell "echo nop > /sys/kernel/debug/tracing/current_tracer"
adb pull /sdcard/ftrace.log ./ftrace.log

