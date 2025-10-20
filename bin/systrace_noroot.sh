set -x

./systrace.py $@ -b 30720 gfx view wm am dalvik sched freq idle load input audio video webview camera hal res rs app bionic
