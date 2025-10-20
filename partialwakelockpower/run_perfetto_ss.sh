#!/bin/bash

adb push perfetto_memprof.cfg /data/misc/perfetto-configs/
adb shell perfetto --txt -c /data/misc/perfetto-configs/perfetto_memprof.cfg -o /data/misc/perfetto-traces/trace
adb pull /data/misc/perfetto-traces/trace
