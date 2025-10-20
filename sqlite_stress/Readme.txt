1. HW:

Foster Pro
PM342 connected
ADB connection

2. SW:

TOT@rel-24, with WAL disabled (default)
TOT@rel-24, with WAL/NORMAL enabled
TOT@rel-24, with WAL/FULL enabled

3. Testing methodology

Device runs SQLiteStress.apk, which will start a specified number of threads,
each doing stress update of an individual database, and keeping the progress
to adb logcat. The host will try to read from adb logcat, showing the progress
on terminal, and detecting database consistency. The host will also reset the
device randomly via PM342 to emulate sudden power loss, and resume the test
after the device reboots.

Ideally, this would be better run with a fidget power control board - the
script will have to be updated for that. A stress of 10,000 cycles (10 devices
each 1000 cycles) is recommended.

Estimation would be for each cycle - from power-on to Android boots up, and
SQLiteStress.apk gets running for a while, is about 2 minutes, presumably 30
cycles per hour x 24 hours = 720 cycles per day. So 1,000 cycles will need
1 and half a day.

4. How to run

4.1 Ensure pm342 is 'visible' (can be found in $PATH, e.g. /usr/bin)
4.2 $ adb root
4.3 $ adb install SQLiteStress.apk
4.4 $ ./pystress.py 3 0 # start stress test with 3 threads without delay

      # Usage: ./pystress.py <thread_number> <delay_in_ms>
      # <thread_number> should be in [1, 255]
      # <delay_in_ms> should be in [0, 10000]
      # Each thread opens a database and write to it in a loop
      # The 1st thread writes to its database for every (1*delay) ms
      # The 2nd thread writes to its database for every (2*delay) ms
      # The 3rd for every 60ms, ..., and the nth for every (n*delay) ms
4.5 The script will stop when
    a) database corruption is detected, or
    b) no logcat messages is recevied in 5 seconds, or
    c) user presses Ctrl-C to stop it.

5. Output

5.1 On data loss, the script will print a warning:

### Data loss detected: error=%d.

It reports how many ("error=%d) database entries are missing (e.g. due to
sudden power loss).

5.2 On incomplete logcat, the script will print another warning:

### Missing logcat detected: error=%d.

It means either a few logcat entries fails to transmit from device to host, or
the adb connection is not stable enough. Generally this is harmless.

5.3 If data loss or missing logcat reaches a threshold, it's considered as
Database corruption. The script will print the following error and exit.

### Corrupted DB detected: error=%d.

5.4 All of the interaction between host and device, as well as the raw logcat
will be saved to stress.log for further analysis.

6. Runtime parameters

Here's the list of default runtime parameters within the python script.

# Runtime parameters
error_threshold = 50            # regard 50 data/logcat loss as db corruption
timeout_reboot = 60             # reboot timeout: 60 seconds
timeout_watchdog = 5            # adb logcat timeout: 5 seconds
timeout_powerloss_min = 10      # reset device after a random period of time
timeout_powerloss_max = 90      # in seconds: random time in [min, max)

