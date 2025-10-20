#!/bin/bash

# sudo apt-get install zenity wmctrl

BLABLA=${1:-"hello"}
ITER=${2:-1}
echo "$0 $BLABLA $ITER"

iii=0
while [[ $iii -lt $ITER ]]; do
        (sleep 1; while ! wmctrl -F -a "I am on top!" -b add,above; do sleep 1; done) &
        (zenity --info --title="I am on top!" --text="[#$iii] $BLABLA")
        iii=$(($iii + 1))
done
