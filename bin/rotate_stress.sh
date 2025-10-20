set -x
adb shell "content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0;"
while true
do
for i in 0 1 2 3
do
adb shell "content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:$i;"
sleep 1
done
done
