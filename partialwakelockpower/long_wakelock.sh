set -x

# Detect PowerHAL version
lshal debug android.hardware.power.stats@1.0::IPowerStats/default
POWER_STAT=$?

# Duration
DURATION=${1:-3}

# Output dir
OUT=/mnt/${2:-test.out}
mkdir -p $OUT

# Workload
shift 2
WORKLOAD=${@:-sleep}

# Turn on airplane mode
settings put global airplane_mode_on 1
am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true

# Disable location
adb shell settings put secure location_providers_allowed -gps
adb shell settings put secure location_providers_allowed -network

# Disable NFC
svc nfc disable

# Disable auto-rotate
settings  put system accelerometer_rotation 0

# Disable Ambient mode
settings put secure doze_enabled 0
settings put secure wake_gesture_enabled 0
settings put secure doze_always_on 0
settings put secure doze_pulse_on_pick_up 0
settings put secure doze_wake_screen_gesture 0
am force-stop com.google.intelligence.sense

# Disable NTP
settings put global auto_time 0
settings  put global auto_timezone 0

# Disable Wifi/BT
svc wifi disable
service call bluetooth_manager 8

# Hold a wakelock
echo dummy_wakelock > /sys/power/wake_lock

# Disconnect USB cable
echo "Please disconnect USB now"
echo 0 > /sys/devices/platform/10d50000.hsi2c/i2c-5/5-0025/cc_toggle_enable # P21
echo 0 > /sys/class/power_supply/usb/cc_toggle_enable # C2/F2/S5/B5/R3
echo 1 > /d/pmic-votable/DISABLE_POWER_ROLE_SWITCH/force_val
echo 1 > /d/pmic-votable/DISABLE_POWER_ROLE_SWITCH/force_active

sleep 1

# Turn off display
input keyevent KEYCODE_POWER

# Log start
sleep 1
log -p f -t TEST "Partial Wakelock Test Start"

# Measure power
if [ $POWER_STAT -eq 0 ]; then
  lshal debug android.hardware.power.stats@1.0::IPowerStats/default > $OUT/power0.log
else
  dumpsys android.hardware.power.stats.IPowerStats/default delta > $OUT/power0.log
fi

for i in $( seq $DURATION ); do
  $( $WORKLOAD )

  if [ $POWER_STAT -eq 0 ]; then
    lshal debug android.hardware.power.stats@1.0::IPowerStats/default > $OUT/power$i.log
  else
    dumpsys android.hardware.power.stats.IPowerStats/default delta > $OUT/power$i.log
  fi
done

# Log end
log -p f -t TEST "Partial Wakelock Test End"

# Turn on display
input keyevent KEYCODE_POWER

# Reconnect USB cable
echo 0 > /d/pmic-votable/DISABLE_POWER_ROLE_SWITCH/force_val
echo 1 > /sys/class/power_supply/usb/cc_toggle_enable # C2/F2/S5/B5/R3
echo 1 > /sys/devices/platform/10d50000.hsi2c/i2c-5/5-0025/cc_toggle_enable # P21

# Release wakelock
echo dummy_wakelock > /sys/power/wake_unlock
