#!/bin/bash

set -x

# godir $TOP/system/extras/simpleperf/scripts

python3 app_profiler.py --system_wide
#python3 app_profiler.py --pid `pid.sh com.android.phone`
#python3 app_profiler.py -p com.android.phone -r "-e task-clock:u -f 1000 -g --duration 30"

python3 pprof_proto_generator.py
python3 report_html.py

mkdir -p mydata
cp perf.data pprof.profile report.html mydata/

# pprof -http=:8080 pprof.profile


#mkdir /data/ramdisk
#mount -t tmpfs -o size=1G tmpfs /data/ramdisk
#simpleperf record -a --exclude-perf -g -o /data/ramdisk/perf.data
