FILE=${1:-".done"}

date
touch /tmp/$FILE

echo "Notifying $FILE"
zenity --title "$FILE" --text "`date`" --info --timeout 3
