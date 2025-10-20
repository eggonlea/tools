adb shell perfetto \
  -c - --txt \
  -o /data/misc/perfetto-traces/trace \
<<EOF

buffers: {
    size_kb: 7168
    fill_policy: DISCARD
}
data_sources: {
    config {
        name: "android.java_hprof"
        target_buffer: 0
        java_hprof_config {
            process_cmdline: "system_server"
            continuous_dump_config {
                dump_phase_ms: 3000
                dump_interval_ms: 3000
            }
        }
    }
}
duration_ms: 10000

EOF

adb pull /data/misc/perfetto-traces/trace
