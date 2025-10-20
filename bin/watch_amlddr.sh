#!/bin/bash

while [ 1 ]; do

adbroot.sh

adb shell 'echo 1 > /sys/class/aml_ddr/mode'
adb shell 'echo 0:0 > /sys/class/aml_ddr/port' # CPU
adb shell 'echo 1:1 > /sys/class/aml_ddr/port' # GPU
#adb shell 'echo 2:10 > /sys/calss/aml_ddr/port' # NPU
#adb shell 'echo 2:2 > /sys/calss/aml_ddr/port' # PCIE
adb shell 'echo 2:21 > /sys/class/aml_ddr/port' # VDEC
adb shell 'echo 3:8 > /sys/class/aml_ddr/port' # H265ENC
#adb shell 'echo 3:34 > /sys/class/aml_ddr/port' # DMA
#adb shell 'echo 3:22 > /sys/class/aml_ddr/port' # HCODEC

	clear
	#. choose_adb.sh
	watch -n 3 -d -E adb shell "cat /sys/class/aml_ddr/bandwidth"
	sleep 1
done

