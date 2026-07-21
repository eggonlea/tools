#!/bin/bash

set -x

adb wait-for-device
sleep 0.1
adb root
sleep 0.1
adb wait-for-device
sleep 0.1

