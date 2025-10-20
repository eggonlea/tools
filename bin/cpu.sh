#!/bin/bash

#set -x

ID=${1:-0}

#adb shell "echo > /dev/null"
adb pull /proc/cpuinfo /tmp/cpuinfo > /dev/null 2> /dev/null
RET=$?
if [ $RET -ne 0 ]; then exit $RET; fi

TMP=/tmp/cpu.$ID
mkdir -p $TMP

function adb_cat
{
	adb pull $1 ${TMP}/$2 > /dev/null 2> /dev/null; cat ${TMP}/$2 2> /dev/null | sed -e 's/[\r\t\n]//g'
}

HW=`adb_cat /proc/cpuinfo cpuinfo | sed -n -e 's/Hardware: //gp'`
echo Platform: [${HW}]
#if [ ${HW} = ardbeg -o ${HW} = tn8 ]; then NCT1=0; NCT2=1; else NCT1=3; NCT2=4; fi
NCT1=0; NCT2=1
VDD=`adb_cat /d/clock/dvfs dvfs | sed -n -e '/vdd_/p'`
THRT=`adb_cat /sys/devices/system/cpu/cpu0/cpufreq/stats/throttle_count throttle`
THER_TYPE1=`adb_cat /sys/devices/virtual/thermal/thermal_zone${NCT1}/type type.${NCT1}`
THER_TEMP1=`adb_cat /sys/devices/virtual/thermal/thermal_zone${NCT1}/temp temp.${NCT1}`
THER_TYPE2=`adb_cat /sys/devices/virtual/thermal/thermal_zone${NCT2}/type type.${NCT2}`
THER_TEMP2=`adb_cat /sys/devices/virtual/thermal/thermal_zone${NCT2}/temp temp.${NCT2}`
FCPU=`adb_cat /d/clock/cpu/rate cpu_rate`
DVFS=`adb_cat /d/clock/dfll_cpu/cl_dvfs/monitor monitor`
CPUA=`adb_cat /sys/kernel/cluster/active active`
CPUS=`adb_cat /sys/devices/system/cpu/online online`
FEMC=`adb_cat /d/clock/emc/rate emc_rate`
FBWM=`adb_cat /d/tegra_bwmgr/emc_rate bwm_emc_rate`
F_3D=`adb_cat /d/clock/3d/rate 3d_rate`
FGKA=`adb_cat /d/gk20a.0/rate gk20a_rate`
FGPU=`adb_cat /d/gpu.0/rate gpu_rate`
FGPM=`adb_cat /d/gpu.0/monitor gpu_monitor`

if [ "x${VDD}" != "x" ]; then echo "${VDD}"; fi
if [ "x${THER_TEMP1}" != "x" ]; then echo "${THER_TYPE1} : ${THER_TEMP1}"; fi
if [ "x${THER_TEMP2}" != "x" ]; then echo "${THER_TYPE2} : ${THER_TEMP2}"; fi
if [ "x${THRT}" != "x" ]; then echo "throttle #: ${THRT}"; fi
if [ "x${FCPU}" != "x" ]; then echo "cpu   freq: ${FCPU}"; fi
if [ "x${DVFS}" != "x" ]; then echo "cl_dvfs fq: ${DVFS}"; fi
if [ "x${CPUA}" != "x" ]; then echo "cluster   : ${CPUA}"; fi
if [ "x${CPUS}" != "x" ]; then echo "online CPU: ${CPUS}"; fi
if [ "x${FEMC}" != "x" ]; then echo "emc   freq: ${FEMC}"; fi
if [ "x${FBWM}" != "x" ]; then echo "bwemc freq: ${FBWM}"; fi
if [ "x${F_3D}" != "x" ]; then echo "3d    freq: ${F_3D}"; fi
if [ "x${FGKA}" != "x" ]; then echo "gk20a freq: ${FGKA}"; fi
if [ "x${FGPU}" != "x" ]; then echo "gpu.0 freq: ${FGPU}"; fi
if [ "x${FGPM}" != "x" ]; then echo "gpu.m freq: ${FGPM}"; fi

top.sh $ID

echo "=== CPU0 DVFS ==="

adb_cat /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state time_in_state_a | sed -e '/ 0\s*$/d'

echo "=== CPU5 DVFS ==="

adb_cat /sys/devices/system/cpu/cpu5/cpufreq/stats/time_in_state time_in_state_b | sed -e '/ 0\s*$/d'

echo "=== EMC DVFS ==="

adb_cat /d/tegra_emc/stats stats | sed -e '/ 0\s*$/d'

