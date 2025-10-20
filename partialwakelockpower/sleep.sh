INT=${1:-1}

COUNT=0
while true; do
  echo $COUNT
  sleep $INT
  COUNT=$(( $COUNT + 1 ))
done
