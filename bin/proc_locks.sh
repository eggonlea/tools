#!bin/bash

adb shell 'while IFS=": " read x x x x p x x i x; do echo ""; cat /proc/$p/cmdline; echo ":"; find -L "/proc/$p/fd" -maxdepth 1 -inum "$i" -exec readlink {} \;; done < /proc/locks'
