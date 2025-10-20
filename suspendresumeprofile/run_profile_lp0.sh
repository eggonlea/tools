# default automatic mode
if [ $# -eq 0 ]; then

	# ensure adb is running as root
	adb root
	sleep 1
	adb wait-for-device

	# default: async=1
	./profile_lp0.sh 1

	sleep 5

	# async=0
	./profile_lp0.sh 0

	DIR=out

# interactive mode
elif [ $1 == '-i' ]; then

	# ensure adb is running as root
	adb root
	sleep 1
	adb wait-for-device

	# default: async=1
	./profile_lp0.sh 1 1

	sleep 5

	# async=0
	./profile_lp0.sh 0 1

	DIR=out

# process existing data only
else
	DIR=$1
fi

# process the data
./profile_lp0.py ${DIR}/trace_async1.log &
./profile_lp0.py ${DIR}/trace_async0.log &

