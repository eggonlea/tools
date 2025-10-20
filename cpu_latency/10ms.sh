BIN=${1:-cpu_latency}

trap 'echo Ctrl-C detected; exit' INT
trap 'echo TERM detected; exit' TERM
trap 'echo Cleanup; adb shell kill -INT `pid.sh cpu_latency | head -1`; kill 0' EXIT

adb wait-for-device
sleep 0.1
adb root
sleep 0.1
adb wait-for-device

adb push ${BIN} /data/cpu_latency
#adb shell '/data/cpu_latency -i 1ms -n 1ms -c 0x8' & 
adb shell '/data/cpu_latency -i 10667us -n 1ms -c 1 \
				-s -i 10667us -n 1ms -c 2 \
				-s -i 10667us -n 1ms -c 4 \
				-s -i 10667us -n 1ms -c 8' &
#while [ 1 ]; do sleep 1; done
while [ 1 ]
do
	sleep 1
	adb shell ps | grep cpu_latency > /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "Target exit or disconnected"
		exit
	fi
done
