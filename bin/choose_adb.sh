#adb start-server
adb devices -l
echo "Default: unset ANDROID_SERIAL"
unset ANDROID_SERIAL
COUNT=`adb devices | sed -e '1d; $d' | wc -l`
if [ ${COUNT} -gt 1 ]; then
	read -p "Please select device [1,n]:" -t 3 NUM
	if [ $? -eq 0 ]; then
		export ANDROID_SERIAL=`adb devices | sed -e 1d | sed -n -e ${NUM}p | sed -e 's/\t.*//g'`
		echo "${ANDROID_SERIAL} selected"
		export REAL_SERIALNO=`adb shell getprop ro.serialno`
		echo "REAL_SERIALNO ${REAL_SERIALNO}"
	fi
fi
echo "Finished."
