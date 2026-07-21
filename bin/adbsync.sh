#!/bin/bash

adbroot.sh

adb shell stop
adb remount
adb sync
adb shell start

