#!/usr/bin/python

import os
import sys
import re
import locale

def usage():
	print 'Usage: %s <trace.html> <threshold in us>' % sys.argv[0]
	sys.exit(1)

def search_id(comm):
	if comm.startswith('cpu_latency') and len(comm) > len('cpu_latency'):
		return int(comm[len('cpu_latency'):])
	return -1
	
def fmt(i):
	return locale.format('%.3f', float(i) / 1000, grouping=True)

# read trace.log or trace.html line by line
def read_data():
	if len(sys.argv) == 3:
		fname = sys.argv[1]
		threshold = int(sys.argv[2])
		if threshold <= 0:
			print 'Invalid threshold %d' % threshold
			usage()
	else:
		print 'Wrong parameters'
		usage()

	try:
		f = open(fname)
	except IOError as e:
		print 'failed to open %s' % fname
		sys.exit(1)

	key = 'cpu_latency'
	keylen = len(key)

	threads = 8
	cpus = [-1 for i in range(threads)]	# run on cpu# previously
	prev = [-1 for i in range(threads)]	# last cpu# scheduled
	maxd = [-1 for i in range(threads)]	# max latency
	start = -1				# beginning of ftrace
	end = -1				# end of ftrace
	count_slowrun   = 0			# @ duration of cpu_latency itself
	count_migration = 0			# = migrated among cpus
	count_slowsched = 0			# # delayed sched
	count_slowsleep = 0			# - delayed nanosleep
	print
	print '@: cpu_latency executes for an unexpected longer period'
	print '=: cpu_latency is migrated among CPUs during runtime'
	print '-: cpu_latency is migrated among CPUs during scheduling time'
	print '#: cpu_latency scheduling is delayed'
	print '+: delayed wakeup from nanosleep detected by cpu_latency itself'
	print
	for line in f:
		line = line.strip()

		# check lost events
		# CPU:0 [LOST 10076 EVENTS]
		m = re.match('CPU:(\d+) \[LOST \d+ EVENTS\]', line)
		if m:
			# reset all threads
			#print '* Events lost on CPU %s' % m.group(1)
			cpus = [-1 for i in range(threads)]
			prev = [-1 for i in range(threads)]
			continue

		# find the timestamp
		m = re.match('.*-\d+\s+\(.*\)\s+\[(\d+)\]\s+....\s+(\d+)\.(\d+): .*', line)
		if m:
			end = int(m.group(2)) * 1000000 + int(m.group(3))
		else:
			# try alternative (irqsoff) format
			m = re.match('.*-\d+\s+(.).... (\d+)us : .*', line)
			if m:
				end = int(m.group(2))
			else:
				continue

		# beginning of ftrace
		if start == -1:
			start = end
			print 'The first trace at %s' % fmt(start)

		# check built-in latency warning
		m = re.match('.*-\d+\s+\(.*\)\s+\[(\d+)\]\s+....\s+(\d+)\.(\d+): tracing_mark_write: .\|\d+\|cpu_latency(\d+)\|(\d+)', line)
		if m:
			# found
			cpu = int(m.group(1))
			curr = int(m.group(2)) * 1000000 + int(m.group(3))
			comm = int(m.group(4))
			delay = int(m.group(5))

			# found slow nanosleep
			if delay * 1000 >= threshold:
				print '+%8d at=%s (%s) delay=%d+   cpu=%d: ---------- %d' % (
					count_slowsleep, fmt(curr - start), fmt(curr),
					delay, cpu, comm)
				count_slowsleep += 1

			continue

		# check sched ftrace
		# cpu_latency3-31998 (31998) [000] d..3 101633.569419: sched_switch: prev_comm=cpu_latency3 prev_pid=31998 prev_prio=97 prev_state=R ==> next_comm=cpu_latency0 next_pid=31995 next_prio=97
		m = re.match('.*-\d+\s+\(.*\)\s+\[(\d+)\]\s+....\s+(\d+)\.(\d+): sched_switch: prev_comm=(\S+) .*next_comm=(\S+) .*', line)
		if m:
			cpu = int(m.group(1))
			curr = int(m.group(2)) * 1000000 + int(m.group(3))
			prev_comm = m.group(4)
			next_comm = m.group(5)
		else:
			# try alternative (irqsoff) format
			#   <idle>-0       0d..3 300286us : sched_switch: prev_comm=swapper/0 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=cpu_latency0 next_pid=3287 next_prio=97
			m = re.match('.*-\d+\s+(.).... (\d+)us : sched_switch: prev_comm=(\S+) .*next_comm=(\S+) .*', line)
			if not m:
				continue

			cpu = int(m.group(1))
			curr = int(m.group(2))
			prev_comm = m.group(3)
			next_comm = m.group(4)

		# found sched-out
		thread = search_id(prev_comm)
		if thread >= 0:
			if prev[thread] == -1:
				continue

			# found runtime migration
			if cpu != cpus[thread]:
				print '=%8d at=%s (%s) migrated %d->%d: %s' % (
					count_migration, fmt(curr - start), fmt(curr),
					cpus[thread], cpu, prev_comm)
				count_migration += 1

			# found slow run
			delta = curr - prev[thread]
			if delta >= threshold:
				print '@%8d at=%s (%s) delta=%d cpu=%d: %s' % (
					count_slowrun, fmt(curr - start), fmt(curr),
					delta, cpu, prev_comm)
				count_slowrun += 1


		# found sched-in
		thread = search_id(next_comm)
		if thread >= 0:
			if prev[thread] == -1:
				prev[thread] = curr
				cpus[thread] = cpu
				continue

			# found sched migration
			if cpu != cpus[thread]:
				print '-%8d at=%s (%s) migrated %d->%d: %s' % (
					count_migration, fmt(curr - start), fmt(curr),
					cpus[thread], cpu, next_comm)
				count_migration += 1

			# found slow sched
			delta = curr - prev[thread]
			if delta >= threshold:
				print '#%8d at=%s (%s) delta=%d cpu=%d: %s' % (
					count_slowsched, fmt(curr - start), fmt(curr),
					delta, cpu, next_comm)
				count_slowsched += 1
			
			# record the max latency
			if delta > maxd[cpu]:
				maxd[cpu] = delta

			prev[thread] = curr
			cpus[thread] = cpu

	# end of ftrace
	if start != -1:
		print 'Duration %s - %s = %s' % (fmt(end), fmt(start), fmt(end - start))

	for i in range(threads):
		if maxd[i] > 0:
			print 'Max latency [%d] = %s' % (i, fmt(maxd[i]))

if __name__ == '__main__':
	locale.setlocale(locale.LC_ALL, '')
	read_data()

