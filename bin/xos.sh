#!/bin/sh

DIR=$1
BUILD1=$2
BUILD2=$3
TITLE=$4

source $(dirname $0)/x.inc

snap
xdotool key F2

snap
xdotool type "cd ~/vobs/$DIR
"
xdotool type '
export TOP=$PWD
export ANDROID_HOME=$HOME/Android/Sdk
#export ALLOW_MISSING_DEPENDENCIES=true
#export INCLUDE_FLUTTER_APPS=true
#export ENV_ENHANCEMENTS=1
. build/envsetup.sh
'
xdotool type "lunch $BUILD1
"
xdotool type 'ls $OUT
export PATH=$HOME/Android/Sdk/platform-tools:$PATH
'

snap
xdotool key Shift+F2
#xdotool key Ctrl+F2
snap
xdotool type "cd ~/vobs/$DIR
"
xdotool type '
export TOP=$PWD
export ANDROID_HOME=$HOME/Android/Sdk
#export ALLOW_MISSING_DEPENDENCIES=true
#export INCLUDE_FLUTTER_APPS=true
#export ENV_ENHANCEMENTS=1
. build/envsetup.sh
'
xdotool type "lunch $BUILD2
"
xdotool type 'ls $OUT
export PATH=$HOME/Android/Sdk/platform-tools:$PATH
'

snap
xdotool key F8
xdotool type "$TITLE
"
enter
