set -x
THREADS=${1:-0}
DELAY=${2:-0}

adb shell am start -e threads ${THREADS} -e delay ${DELAY} -n com.example.lli5.sqlitestress/.MainActivity
