trap 'echo Ctrl-C detected; exit' INT
trap 'echo TERM detected; if [ $# -eq 1 ]; then adb pull /data/strace.log; fi; exit' TERM
trap 'echo Cleanup; kill 0' EXIT

if [ $# -ne 1 ]; then
echo "Usage: $0 <pid>"
exit
fi

adbroot.sh

adb shell rm -f /data/strace.log
adb shell sync
adb shell strace -C -f -F -v -T -tt -o /data/strace.log -p $1
