set -x

adbroot.sh

DIR=${1:-"/data"}

rm -f /tmp/iwait.log
#touch /tmp/iwait.log

adb push ~/bin/iwait /data/
adb shell "/data/iwait --format '%T %w %e %f' --timefmt '%c' -m -r $DIR" | tee -a /tmp/iwait.log

