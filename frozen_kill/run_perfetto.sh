cat config.pbtx | adb shell perfetto -c - --txt -o /data/misc/perfetto-traces/trace.pftrace
adb pull /data/misc/perfetto-traces/trace.pftrace
