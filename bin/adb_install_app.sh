#!/bin/bash

set -x

APP=${1:-'com.google.android.apps.adm'}

adb shell am start -a android.intent.action.VIEW -d "market://details?id=$APP"
adb shell uiautomator dump
adb pull /sdcard/window_dump.xml /tmp/
read -r x y < <(cat /tmp/window_dump.xml | perl -ne '/.*<node.*?Install.*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]".*/ && print $0/2+$3/2, " ", $2/2+$4/2, "\n";')
if [[ -n $x && -n $y ]]; then
  adb shell input tap $x $y
else
  echo "Can't install $APP"
fi

