PID=`adb shell pidof system_server`
#./run.sh 900 test.out simpleperf record -a -g --post-unwind=yes -m 8192 -o /mnt/test.out/perf.data -f 1000 --log info sleep
./run_partial.sh 900 test.out simpleperf record -p $PID -g --post-unwind=yes -m 8192 -o /mnt/test.out/perf.data -f 1000 --log info sleep
#./run.sh 900 test.out simpleperf record -p $PID -e cpu-cycles -e task-clock:u -e kprobes:mm_fault -g --post-unwind=yes -m 8192 -o /mnt/test.out/perf.data -f 1000 --log info sleep

