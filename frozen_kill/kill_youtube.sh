#!/bin/sh

YOUTUBE="com.google.android.youtube"
DESKCLOCK="com.google.android.deskclock"
DIALER="com.google.android.dialer"
CONTACTS="com.google.android.contacts"

adbroot.sh

adb logcat -c

launchapp.sh $YOUTUBE
sleep 3

./run_perfetto.sh &

launchapp.sh $DESKCLOCK
sleep 1
launchapp.sh $YOUTUBE
sleep 1
launchapp.sh $DIALER
sleep 1
launchapp.sh $CONTACTS
sleep 1
adb shell input keyevent KEYCODE_HOME

PID_YOUTUBE=`pid.sh $YOUTUBE`
PID_DESKCLOCK=`pid.sh $DESKCLOCK`
PID_DIALER=`pid.sh $DIALER`
PID_CONTACTS=`pid.sh $CONTACTS`

echo "Waiting for YouTube to be frozen..."
while true; do
	FREEZE=`adb shell "cat /sys/fs/cgroup/*/*/pid_$PID_YOUTUBE/cgroup.freeze"`
	if [ $FREEZE -eq 1 ]; then
		break
	else
		sleep 0.1
	fi
done
echo "YouTube frozen"

sleep 0.3

echo "Unfreezing apps..."
launchapp.sh $DESKCLOCK
sleep 0.3
launchapp.sh $YOUTUBE
sleep 0.3
launchapp.sh $DIALER
sleep 0.3
launchapp.sh $CONTACTS
sleep 0.3
adb shell input keyevent KEYCODE_HOME

echo "Waiting for YouTube to be frozen..."
while true; do
	FREEZE=`adb shell "cat /sys/fs/cgroup/*/*/pid_$PID_YOUTUBE/cgroup.freeze"`
	if [ $FREEZE -eq 1 ]; then
		break
	else
		sleep 0.1
	fi
done
echo "YouTube frozen"

sleep 0.3

echo "Killing $PID_DESKCLOCK com.google.android.deskclock"
adb shell kill -9 $PID_DESKCLOCK
echo "Killing $PID_YOUTUBE $YOUTUBE"
adb shell kill -9 $PID_YOUTUBE
sleep 1

echo "Waiting for perfetto to finish..."
wait

adb logcat -d > logcat.log
