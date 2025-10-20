if [ $# -lt 2 ]
then
	echo "Usage: $0 <delay> <command>"
	exit
fi

COUNT=0
DELAY=$1
shift
while [ 1 ]
do
	echo "Run #$COUNT... [$@]"
	sleep $DELAY
	time $@
	echo "Done."

	(( COUNT++))
done
