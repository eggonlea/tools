#!bin/bash

set -x

# Buffer size
BUFFER_ARGS="-b 4096"

# Extra trace events
#EXTRA_TRACE_EVENTS="timer migrate lowmemorykiller" # zram_drv"
EXTRA_TRACE_EVENTS="fsync:* mm_filemap_sleep_on_page_io_begin mm_filemap_sleep_on_page_io_end"

# Starting async atrace
function start_atrace
{
echo "Starting atrace..."
for i in ${EXTRA_TRACE_EVENTS}
do
	echo "Enabling extra trace event $i"
	#adb shell "echo 1 > /d/tracing/events/$i/enable"
	adb shell "echo $i >> /d/tracing/set_event"
done

adb shell "atrace ${BUFFER_ARGS} ${EXTRA_ARGS} --async_start database"
#adb shell "atrace ${BUFFER_ARGS} ${EXTRA_ARGS} --async_start gfx input view webview wm am sm audio video camera hal res dalvik rs bionic power pm ss database network adb vibrator aidl nnapi rro sysprop core_services pdx sched irq i2c freq idle disk sync workq memreclaim regulators binder_driver binder_lock pagecache memory thermal freq gfx ion lmh_dcvs memory"
#-k get_page_from_freelist,__alloc_pages_slowpath,wake_all_kswapd
}

# Stopping async atrace
function stop_atrace
{
echo "Stopping atrace..."
for i in ${EXTRA_TRACE_EVENTS}
do
	echo "Disabling extra trace event $i"
	#adb shell "echo 0 > /d/tracing/events/$i/enable"
done
adb shell "echo "" > /d/tracing/set_event"

#adb shell "atrace ${BUFFER_ARGS} -z --async_stop > /data/atrace.log"
adb shell "atrace --async_stop -z -o /data/atrace.log"
adb pull /data/atrace.log
#./run_systrace.py --from-file=./atrace.log
}

# Main script body
trap 'echo Ctrl-C detected; exit' INT
trap 'echo TERM detected; stop_atrace; exit' TERM
trap 'echo Cleanup; kill 0' EXIT

if [ $# -eq 1 ]; then
EXTRA_ARGS="-a $1"
fi

adbroot.sh

adb shell rm -f /data/atrace.log
adb shell sync

start_atrace

while [ 1 ]; do
sleep 1
done

