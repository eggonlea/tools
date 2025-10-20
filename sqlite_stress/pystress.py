#! /usr/bin/env python

import Queue
import subprocess
import threading
import time
import re
import sys
import signal
import random

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

def bye(dump = False):
	global running
	if not running:
		return
	running = False
	timer_watchdog.cancel()
	timer_powerloss.cancel()
	subprocess.call(['adb', 'shell', 'am', 'force-stop', 'com.example.lli5.sqlitestress'])
	if dump:
		subprocess.call(['adb', 'pull', '/data/data/com.example.lli5.sqlitestress', './stress_data/'])
		log_print('\n*** raw stress database pulled to ./stress_data/.\n')
		try:
			fbug = open('bugreport.log', 'w')
			subprocess.call(['adb', 'bugreport'], stdout=fbug)
			fbug.close()
			log_print('\n*** bugreport.log saved.\n')
		except:
			log_print('\n### Failed to save bugreport.\n')
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
		bye(True)
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

def reset_sqlite():
	subprocess.call(['adb', 'shell', 'pm', 'clear', 'com.example.lli5.sqlitestress'])
	subprocess.call(['adb', 'logcat', '-c'])
	log_print('\n*** Reset stress test app.\n')

def launch_sqlite(threads, delay):
	subprocess.call(['adb', 'shell', 'am', 'start',
		'-e', 'threads', '%d' % threads,
		'-e', 'delay', '%d' % delay,
		'-n', 'com.example.lli5.sqlitestress/.MainActivity'])

def stress_sqlite(counts):
	global heartbeat

	# You'll need to add any command line arguments here.
	adb = subprocess.Popen(['adb', 'logcat', '-s', 'SQLiteStress:V'],
		stdout=subprocess.PIPE)

	# Launch the asynchronous readers of the adb' stdout.
	lines = Queue.Queue()
	reader = AsynchronousFileReader(adb.stdout, lines)
	reader.start()

	# Check the queues if we received some output (until there is nothing more to get).
	log_print('*** Starting stress... #%d\n' % stress_sqlite.count)
	stress_sqlite.count += 1

	try:
		while running and not reader.eof():
			while not lines.empty():
				line = lines.get()
				log_write(line)
				m = re.match('.*SQLiteStress: #(\d+) setCount: (\d+)', line.strip())
				if not m:
					continue
				thread = int(m.group(1))
				count  = int(m.group(2))

				while thread >= len(counts):
					counts.append(0)

				error = count - counts[thread] - 1
				if error < -error_threshold or error > error_threshold:
					log_print('\n### Corrupted DB detected: error=%d.\n' % error)
					log_print('Thread: %d\n' % thread)
					log_print('Last  : %d\n' % counts[thread])
					log_print('Expect: %d\n' % (counts[thread] + 1))
					log_print('Get   : %d\n' % count)
					bye(True)
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

	log_print('\n*** Warning: adb logcat exits. Try restarting.\n')

def usage():
	print 'Usage: %s <thread_number> <delay_in_ms>' % sys.argv[0]
	print '\t<thread_number> should be in [1, 255]'
	print '\t<delay_in_ms> should be in [0, 10000]'
	sys.exit(0)

# Runtime parameters
error_threshold = 50		# regard 50 data/logcat loss as db corruption
timeout_reboot = 60		# reboot timeout: 60 seconds
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
stress_sqlite.count = 0

if __name__ == '__main__':
	threads = 0
	delay = 0
	if len(sys.argv) != 3:
		usage()

	threads = int(sys.argv[1])
	if threads <= 0 or threads > 255:
		print 'Invalid threads number: %d' % threads
		usage()

	delay = int(sys.argv[2])
	if delay < 0 or delay > 10000:
		print 'Invalid delay (in ms): %d' % delay
		usage()

	log_open('stress.log')
	signal.signal(signal.SIGINT, handler)
	adb_root()
	reset_sqlite()
	launch_sqlite(threads, delay)
	kick_powerloss()
	kick_watchdog()
	counts = []
	while running:
		if rebooting:
			log_print('*** Rebooting... Wait for %d seconds.\n' % timeout_reboot)
			time.sleep(timeout_reboot)
			adb_root()
			rebooting = False
			launch_sqlite(threads, delay)
			kick_powerloss()
		stress_sqlite(counts)
	bye()
