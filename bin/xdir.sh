#!/bin/sh

DIR1=$1
DIR2=$2
TITLE=$3

source $(dirname $0)/x.inc

snap
xdotool key F2
snap
xdotool type "cd ~/vobs/$DIR1
"
enter

snap
xdotool key Shift+F2
#xdotool key Ctrl+F2
snap
xdotool type "cd ~/vobs/$DIR2
"
enter

snap
xdotool key F8
snap
xdotool type "$TITLE
"
enter
