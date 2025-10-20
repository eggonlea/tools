PIDS=`ls /proc/`
rm -rf /data/smaps.dump
for pid in $PIDS
do
	if [ -e /proc/$pid/comm ]; then
		COMM=`cat /proc/$pid/comm`
		echo "### /proc/$pid/comm [$COMM] ###" >> /data/smaps.dump
	fi
	if [ -e /proc/$pid/oom_adj ]; then
		OOM_ADJ=`cat /proc/$pid/oom_adj`
		echo "### /proc/$pid/oom_adj [$OOM_ADJ] ###" >> /data/smaps.dump
	fi
	if [ -e /proc/$pid/oom_score ]; then
		OOM_SCORE=`cat /proc/$pid/oom_score`
		echo "### /proc/$pid/oom_score [$OOM_SCORE] ###" >> /data/smaps.dump
	fi
	if [ -e /proc/$pid/oom_score_adj ]; then
		OOM_SCORE_ADJ=`cat /proc/$pid/oom_score_adj`
		echo "### /proc/$pid/oom_score_adj [$OOM_SCORE_ADJ] ###" >> /data/smaps.dump
	fi
	if [ -e /proc/$pid/smaps ]; then
		echo "### /proc/$pid/smaps ###" >> /data/smaps.dump
		cat /proc/$pid/smaps >> /data/smaps.dump
	fi
done
