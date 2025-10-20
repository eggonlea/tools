set -x
adb push _get_smaps.sh /data/
adb shell /data/_get_smaps.sh
adb pull /data/smaps.dump
