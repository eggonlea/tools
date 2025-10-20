#!/bin/sh

source $(dirname $0)/x.inc

#gtk-launch google-chrome http://gmail.com https://mail.google.com/mail/u/1/#inbox http://localhost:8080/source/ &
#gtk-launch chromium-browser &
#gtk-launch firefox &
#gtk-launch thunderbird &
#xdotool getwindowactive set_window --name "Google Chrome"
#xdotool search "Google Chrome" windowactivate
#xdotool key Ctrl+Super+Left
#xdotool key Super+Left

#if [ "x${CHROME_REMOTE_DESKTOP_SESSION}" == "x" ]
#then
#  gtk-launch google-chrome &
#  sleep 3
#fi

# Start new session
setsid

gtk-launch byobu &
sleep 3

#xdotool getwindowactive set_window --name "Byobu Terminal"
#xdotool search byobu windowactivate
#xdotool key Ctrl+Super+Right
if [ "x${CHROME_REMOTE_DESKTOP_SESSION}" == "x" ]
then
  xdotool key Super+Right
else
  xdotool key Alt+F10
fi

snap
xdotool type 'dmesg -w
'

snap
xdotool key Shift+F2
snap
xdotool type 'cd ~/work/freezer
date
'

snap
xdotool key Ctrl+F2
snap
xdotool type 'cd ~/work/freezer
date
'

snap
xdotool key F8
xdotool type 'CONSOLE
'
enter

xos.sh android aosp_cf_x86_64_phone-trunk_staging-userdebug aosp_cf_x86_64_phone-trunk_staging-userdebug CF
xos.sh main oriole-trunk_staging-userdebug caiman-next-userdebug O6-CM4-main

if command -v smartsync &> /dev/null
then
  # Cloud
#  xrb.sh tm-mainline-prod Rb
  xos_rbe.sh aosp aosp_cf_x86_64_phone-trunk_staging-userdebug aosp_oriole-trunk_staging-userdebug CF-O6-aosp
#  xdir.sh kernel/flame kernel/flame F2-4.14
#  xdir.sh kernel/redfin kernel/redfin R3-4.19
  xdir.sh kernel/oriole kernel/oriole O6-mainline
  xdir.sh kernel/bluejay kernel/bluejay B3-5.10
  xdir.sh kernel/common-android11-5.4 kernel/common-android12-5.4 ACK-5.4
  xdir.sh kernel/common-android12-5.10 kernel/common-android13-5.10 ACK-5.10
  xdir.sh kernel/common-android13-5.15 kernel/common-android14-5.15 ACK-5.15
  xdir.sh kernel/common-android14-6.1 kernel/common-android14-6.1 ACK-6.1
  xdir.sh kernel/linux kernel/linux linux
else
  # Local
  xdir.sh kernel/flame kernel/redfin  PxlKnl
fi

snap
xdotool key F4


# 2nd Profile
#if [ "x${CHROME_REMOTE_DESKTOP_SESSION}" == "x" ]
#then
#  xdotool key Ctrl+Alt+Right
#  gtk-launch chrome-profile2 &
#  sleep 1
#  xdotool key Ctrl+Alt+Left
#fi
