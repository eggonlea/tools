FILE=${1:-".done"}

date
echo "Waiting for $FILE"
zenity --text "Waiting for file\n$FILE" --notification

while read i; do if [ "$i" = $FILE ]; then break; fi; done \
   < <(inotifywait  -e create,open --format '%f' --quiet /tmp --monitor)

date
echo "Detected $FILE"
zenity --text "File $FILE detected" --notification
