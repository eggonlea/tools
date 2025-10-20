#! /usr/bin/env python

import Queue
import subprocess
import threading
import time
import re
import sys
import signal
import random
import shutil
import os

class AsynchronousFileReader(threading.Thread):
	'''
	Helper class to implement asynchronous reading of a file
	in a separate thread. Pushes read lines on a queue to
	be consumed in another thread.
	'''

	def __init__(self, fd, queue):
		assert isinstance(queue, Queue.Queue)
		assert callable(fd.readline)
		threading.Thread.__init__(self)
		self._fd = fd
		self._queue = queue

	def run(self):
		'''The body of the tread: read lines and put them on the queue.'''
		for line in iter(self._fd.readline, ''):
			self._queue.put(line)

	def eof(self):
		'''Check whether there is no more content to expect.'''
		return not self.is_alive() and self._queue.empty()

def log_open(fname):
	global flog
	try:
		flog = open(fname, 'w')
		log_print('Open logfile: %s\n' % fname)
	except:
		flog = None
		print 'Failed to open logfile: %s.' % fname

def log_close():
	global flog

	if flog is not None:
		log_print('Close logfile.\n')
		flog.close()
		flog = None

def log_write(msg):
	if flog is not None:
		flog.write(msg)

def log_print(msg):
	log_write(msg)
	print(msg),

def bye():
	global running
	if not running:
		return
	running = False
	timer_watchdog.cancel()
	timer_powerloss.cancel()
	subprocess.call(['adb', 'pull', '/data/fsync', './fsync.out/'])
	try:
		fbug = open('./fsync.out/dmesg.log', 'w')
		subprocess.call(['adb', 'shell', 'dmesg'], stdout=fbug)
		fbug.close()
		log_print('\n*** dmesg.log saved.\n')
	except:
		log_print('\n### Failed to save dmesg.\n')
	log_close()
	sys.exit(0)

def handler(signum, frame):
	if signum == signal.SIGINT:
		log_print('\n### Ctrl-C detected.\n')
		bye()

def watchdog():
	global heartbeat
	
	if rebooting:
		return
	if not heartbeat:
		log_print('\n### Heartbeat watchdog expired.\n')
		bye()
	heartbeat = False
	kick_watchdog()

def powerloss():
	global rebooting
	rebooting = True
	subprocess.call(['pm342', 'reset'])
	log_print('\n*** Random pm342 reset #%d\n' % powerloss.count)
	powerloss.count += 1

def kick_watchdog():
	global timer_watchdog
	timer_watchdog = threading.Timer(timeout_watchdog, watchdog)
	timer_watchdog.start()

def kick_powerloss():
	global timer_powerloss
	timeout_powerloss = random.randrange(timeout_powerloss_min, timeout_powerloss_max)
	timer_powerloss = threading.Timer(timeout_powerloss, powerloss)
	timer_powerloss.start()
	log_print('*** Power loss after %d seconds...\n' % timeout_powerloss)

def adb_root():
	subprocess.call(['adb', 'wait-for-device'])
	subprocess.call(['adb', 'root'])
	time.sleep(1)
	subprocess.call(['adb', 'wait-for-device'])
	log_print('\n*** adb root\'ed.\n')

def reset_fsync():
	subprocess.call(['adb', 'shell', 'rm', '-rf', '/data/fsync'])
	subprocess.call(['adb', 'shell', 'mkdir', '/data/fsync/'])
	subprocess.call(['adb', 'push', './fdatasync', '/data/fsync/'])
	log_print('\n*** Reset stress test app.\n')

def stress_fsync():
	global heartbeat
	global count

	# You'll need to add any command line arguments here.
	adb = subprocess.Popen(['adb', 'shell', '/data/fsync/fdatasync', '10'],
		stdout=subprocess.PIPE)

	# Launch the asynchronous readers of the adb' stdout.
	lines = Queue.Queue()
	reader = AsynchronousFileReader(adb.stdout, lines)
	reader.start()

	# Check the queues if we received some output (until there is nothing more to get).
	log_print('*** Starting stress... #%d\n' % stress_fsync.count)
	stress_fsync.count += 1

	try:
		while running and not reader.eof():
			while not lines.empty():
				line = lines.get()
				log_write(line)
				m = re.match('#(\d+) write buf = (\d+)', line.strip())
				if not m:
					continue
				thread = int(m.group(1))
				count  = int(m.group(2))

				while thread >= len(counts):
					counts.append(0)

				error = count - counts[thread] - 1
				if error < -error_threshold or error > error_threshold:
					log_print('\n### Corrupted data detected: error=%d.\n' % error)
					log_print('Thread: %d\n' % thread)
					log_print('Last  : %d\n' % counts[thread])
					log_print('Expect: %d\n' % (counts[thread] + 1))
					log_print('Get   : %d\n' % count)
					bye()
				elif error < 0:
					log_print('\n### Data loss detected: error=%d.\n' % error)
					log_print('Thread: %d\n' % thread)
					log_print('Last  : %d\n' % counts[thread])
					log_print('Expect: %d\n' % (counts[thread] + 1))
					log_print('Get   : %d\n' % count)
				elif error > 0:
					log_print('\n### Missing logcat detected: error=%d.\n' % error)
					log_write('Thread: %d\n' % thread)
					log_write('Last  : %d\n' % counts[thread])
					log_write('Expect: %d\n' % (counts[thread] + 1))
					log_write('Get   : %d\n' % count)
				counts[thread] = count
				heartbeat = True
				status = ' '.join(str(i) for i in counts)
				print('\r' + status),
	finally:
		adb.kill()

	log_print('\n*** Warning: adb shell exits. Try restarting...\n')

# Runtime parameters
error_threshold = 50		# regard 50 data/logcat loss as db corruption
timeout_reboot = 40		# reboot timeout: 60 seconds
timeout_watchdog = 5		# adb logcat timeout: 5 seconds
timeout_powerloss_min = 5	# reset device after a random period of time
timeout_powerloss_max = 10	# in seconds: random time in [min, max)

# Internal variables
heartbeat = True
running = True
rebooting = False
flog = None

# Record the cycles
powerloss.count = 0
stress_fsync.count = 0

if __name__ == '__main__':
	shutil.rmtree('./fsync.out', ignore_errors = True)
	os.mkdir('./fsync.out')
	log_open('./fsync.out/stress.log')
	signal.signal(signal.SIGINT, handler)
	adb_root()
	reset_fsync()
	kick_powerloss()
	kick_watchdog()
	counts = []
	while running:
		if rebooting:
			log_print('*** Rebooting... Wait for %d seconds.\n' % timeout_reboot)
			time.sleep(timeout_reboot)
			adb_root()
			rebooting = False
			kick_powerloss()
		stress_fsync()
	bye()
