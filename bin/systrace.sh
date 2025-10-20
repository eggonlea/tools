set -x

# godir external/chromium-trace

/srv/vobs/catapult/systrace/bin/systrace $@ gfx input view webview wm am sm audio video camera hal res dalvik rs bionic power pm ss database network adb vibrator aidl nnapi rro sysprop core_services sched irq i2c freq idle disk sync workq memreclaim regulators binder_driver binder_lock pagecache memory freq gfx ion lmh_dcvs memory -b 64000 -a '*'

#./systrace.py $@ gfx input view webview wm am sm audio video camera hal res dalvik rs bionic power pm ss database network adb vibrator aidl nnapi rro sysprop core_services sched irq i2c freq idle disk sync workq memreclaim regulators binder_driver binder_lock pagecache memory thermal freq gfx ion lmh_dcvs memory -b 64000 -a '*'

#./systrace.py $@ gfx input view webview wm am sm audio video camera hal app res dalvik rs bionic power pm ss database network sched irq freq idle disk mmc load sync workq memreclaim regulators binder_driver binder_lock pagecache -a com.essential.klik
#./systrace.py $@ -b 512000 gfx input view webview wm am sm audio video camera hal app res dalvik rs bionic power pm ss database network sched irq freq idle disk mmc load sync workq memreclaim regulators binder_driver binder_lock pagecache -a com.essential.klik
#-k get_page_from_freelist,__alloc_pages_slowpath,wake_all_kswapd

# ~/catapult/systrace/systrace/run_systrace.py sched freq idle am wm gfx irq view workq hal memory binder_driver pm camera  dalvik bionic  input res ion ss -b 32000 -a '*' -o redfin_spotify_maybe_animator_stop3.html
