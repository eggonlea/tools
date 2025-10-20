#!/usr/bin/python

import os
import sys
import re
import operator
import subprocess
from datetime import datetime
import matplotlib.pyplot as plt

SUSPEND = 0
RESUME = 1

modes = ['suspend', 'resume']

rainbow = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet']
color = 0

def get_color():
	global color
	ret = rainbow[color]
	color = color + 1 if color < len(rainbow) - 1 else 0
	return ret

class Dev:
	start = None
	length = None
	async = None
	info = None
	def __init__(self, start = None, length = None, async = None, info = None):
		self.start = start
		self.length = length
		self.async = async
		self.info = info
	
class Data:
	fname =	''			# trace.log
	mode =	None			# lp0 or lp1
	suspended = 0			# real suspended duration
	maps =	[{}, {}]		# parsed raw data
	count =	[0, 0]			# count of devices
	accum =	[0, 0]			# accum time of devices
	real =	[0, 0]			# real suspend/resume time
	devs =	[[0, 0], [0, 0]]	# devices suspend/resume latency
	key =	[[0, 0], [0, 0]]	# power key latency
	touch =	[[0, 0], [0, 0]]	# touch switch latency
	disp =	[[0, 0], [0, 0]]	# disp switch latency
	full =	[[0, 0], [0, 0]]	# the whole suspend/resume duration

	# pie
	plables = [[], []]
	pfracs = [[], []]
	pcolors = [[], []]

	# broken bar
	bbarhs = [[[]], [[]]]
	bcolors = [[[]], [[]]]

	def start_dev(self, mode, t, func, dev, async = 0):
		if self.devs[mode][0] == 0 and func is not None:
			self.devs[mode][0] = t
		if dev not in self.maps[mode]:
			self.maps[mode][dev] = Dev(start = t, async = async)
		else:
			print 'Warning: duplicate device %s: [%s]' % (func, dev)

	def end_dev(self, mode, t, func, dev, info = None):
		if self.devs[mode][1] < t and func is not None:
			self.devs[mode][1] = t
		if dev in self.maps[mode]:
			d = self.maps[mode][dev]
			if t <= d.start:
				print('Warning: disordered device %s: [%s] (%d,%d)'
						% (func, dev, d.start, t))
				t = d.start
			d.length = t - d.start
			d.info = None if info == 'NULL' else info
			self.count[mode] += 1
			self.accum[mode] += d.length
		else:
			print 'Warning: missing device %s: [%s]' % (func, dev)

def usage():
	print 'Usage: %s [trace.log]' % sys.argv[0]
	sys.exit(1)

def parse_cmd():
	global data

	if len(sys.argv) == 1:
		data.fname = 'trace.log'
	elif len(sys.argv) == 2:
		data.fname = sys.argv[1]
	else:
		usage()

# read trace.log line by line
def read_data():
	global data

	try:
		f = open(data.fname)
	except IOError as e:
		print 'failed to open "{0}":({1}) {2}'.format(
				data.fname, e.errno, e.strerror)

	mode = None

	for line in f:
#              sh-20951 [000] ...1  1703.315221: tracing_mark_write: === START SUSPEND RESUME PROFILING ===

		m = re.match('.*-\d+\s+\[\d{3}\]\s....\s+(\d+\.\d+): (\S+):(.*)',
				line.strip())
		if not m:
			continue

		t = float(m.group(1)) * 1000000
		func = m.group(2)
		msg = m.group(3).strip()

		if func == '__device_suspend' or func == 'device_resume':
			mm = re.match('#<< \((\S+), (\d)\)', msg)
			if mm:
				dev = mm.group(1)
				async = int(mm.group(2))
				data.start_dev(mode, t, func, dev, async)
				continue
			mm = re.match('@>> \((\S+), (.*)\)', msg)
			if mm:
				dev = mm.group(1)
				info = mm.group(2)
				data.end_dev(mode, t, func, dev, info)
				continue
		elif func == 'tracing_mark_write':
			if msg == '=== START SUSPEND RESUME PROFILING ===':
				mode = SUSPEND
				continue
			if msg == '=== STOP SUSPEND RESUME PROFILING ===':
				mode = None
				continue
			mm = re.match('mode=(lp\d)', msg)
			if mm:
				data.mode = mm.group(1)
				continue
			mm = re.match('suspend_time=(\d+)ms', msg)
			if mm:
				data.real[SUSPEND] = int(mm.group(1))
				continue
			mm = re.match('resume_time=(\d+)ms', msg)
			if mm:
				data.real[RESUME] = int(mm.group(1))
				continue
		elif func == 'cpu_suspend':
			mm = re.match('state (\d), time (\d+)', msg)
			if mm:
				state = int(mm.group(1))
				if state == 0:
					data.full[SUSPEND][1] = t
					mode = None
				elif state == 1:
					mode = RESUME
					data.full[RESUME][0] = t
				else:
					print 'Warning: wrong cpu_suspend state: %d' % state
			else:
				print 'Warning: wrong cpu_suspend trace: [%s]' % msg
		elif func == 'syscore_suspend':
			data.full[SUSPEND][1] = t
			mode = None
		elif func == 'syscore_resume':
			mode = RESUME
			data.full[RESUME][0] = t
		elif func == 'tegra_dc_disable' or func == 'tegra_dc_disable_irq_ops':
			mm = re.match('#<< \((\S+)\)', msg)
			if mm:
				data.disp[SUSPEND][0] = t
				continue
			mm = re.match('@>> \((\S+)\)', msg)
			if mm:
				data.disp[SUSPEND][1] = t
				continue
		elif func == 'tegra_dc_enable':
			mm = re.match('#<< \((\S+)\)', msg)
			if mm:
				data.disp[RESUME][0] = t
				continue
			mm = re.match('@>> \((\S+)\)', msg)
			if mm:
				data.disp[RESUME][1] = t
				continue
		elif func == 'gpio_keys_gpio_report_event' or func == 'gpio_keys_gpio_report_event.isra.3':
			mm = re.search('type=1, code=116, state=(\d)', msg)
			if mm:
				state = int(mm.group(1))
				if state != 0 and state != 1:
					print 'Warning: wrong key state: %d' % state
				else:
					data.key[mode][1 - state] = t
		elif func == 'console':
			mm = re.search('Raydium - Disable input device done$'
					'|touch_fusion driver: suspend\.\.\.done$',
					msg)
			if mm and mode == SUSPEND:
				data.touch[mode][1] = t
				continue

			mm = re.search('Raydium - Disable input device$'
					'|touch_fusion driver: suspending\.\.\.$',
					msg)
			if mm and mode == SUSPEND:
				data.touch[mode][0] = t
				continue

			mm = re.search('Raydium - Enable input device done$'
					'|touch_fusion driver: resume\.\.\.done$',
					msg)
			if mm and mode == RESUME:
				data.touch[mode][1] = t
				continue

			mm = re.search('Raydium - Enable input device$'
					'|touch_fusion driver: resuming\.\.\.$',
					msg)
			if mm and mode == RESUME:
				data.touch[mode][0] = t
				continue

			mm = re.match('\[\s*\d+\.\d+\] Suspended for (\d+\.\d+) seconds', msg)
			if mm:
				data.suspended = float(m.group(1)) * 1000000
				continue
		else:
			# do nothing
			pass

	f.close()

# normalize data (timestamp)
def norm_data():
	global data

	if data.full[SUSPEND][1] == 0:
		print 'Error: failed to detect suspend.'
		sys.exit(1)

	if data.full[RESUME][0] == 0:
		print 'Error: failed to detect resume.'
		sys.exit(1)

	data.full[SUSPEND][0] = data.key[SUSPEND][0]
	data.full[RESUME][1] = data.disp[RESUME][1]

	if data.key[RESUME][0] == 0:
		data.key[RESUME][0] = data.full[RESUME][0]

	def norm_t(x):
		return (x - zero) / 1000.0

	# suspend
	zero = data.disp[SUSPEND][1]
	print 'suspend zero = %d' % zero
	data.accum[SUSPEND] /= 1000.0
	data.devs[SUSPEND][0] = norm_t(data.devs[SUSPEND][0])
	data.devs[SUSPEND][1] = norm_t(data.devs[SUSPEND][1])
	data.key[SUSPEND][0] = norm_t(data.key[SUSPEND][0])
	data.key[SUSPEND][1] = norm_t(data.key[SUSPEND][1])
	data.touch[SUSPEND][0] = norm_t(data.touch[SUSPEND][0])
	data.touch[SUSPEND][1] = norm_t(data.touch[SUSPEND][1])
	data.disp[SUSPEND][0] = norm_t(data.disp[SUSPEND][0])
	data.disp[SUSPEND][1] = norm_t(data.disp[SUSPEND][1])
	data.full[SUSPEND][0] = norm_t(data.full[SUSPEND][0])
	data.full[SUSPEND][1] = norm_t(data.full[SUSPEND][1])
	for k, v in data.maps[SUSPEND].items():
		v.start = norm_t(v.start)
		v.length /= 1000.0

	# resume
	zero = data.full[RESUME][0]
	print 'resume zero = %d' % zero
	data.accum[RESUME] /= 1000.0
	data.devs[RESUME][0] = norm_t(data.devs[RESUME][0])
	data.devs[RESUME][1] = norm_t(data.devs[RESUME][1])
	data.key[RESUME][0] = norm_t(data.key[RESUME][0])
	data.key[RESUME][1] = norm_t(data.key[RESUME][1])
	data.touch[RESUME][0] = norm_t(data.touch[RESUME][0])
	data.touch[RESUME][1] = norm_t(data.touch[RESUME][1])
	data.disp[RESUME][0] = norm_t(data.disp[RESUME][0])
	data.disp[RESUME][1] = norm_t(data.disp[RESUME][1])
	data.full[RESUME][0] = norm_t(data.full[RESUME][0])
	data.full[RESUME][1] = norm_t(data.full[RESUME][1])
	for k, v in data.maps[RESUME].items():
		v.start = norm_t(v.start)
		v.length /= 1000.0

def draw_piebar(p1, p2, mode):
	sorted_maps = sorted(data.maps[mode].iteritems(), key = lambda i:
			i[1].length, reverse = True)

	other = 0

	def add_frac(name, length, color):
		data.plables[mode].append('%s:%.1f' % (name, length))
		data.pfracs[mode].append(length)
		data.pcolors[mode].append(color)

	def intersect_bbarh(bbarhs, start, length):
		for s, l in bbarhs:
			if s + l <= start or s >= start + length:
				continue
			else:
				return True
		return False

	def add_bbarh(start, length, color):
		for bbarhs, bcolors in zip(data.bbarhs[mode], data.bcolors[mode]):
			if intersect_bbarh(bbarhs, start, length):
				continue
			bbarhs.append((start, length))
			bcolors.append(color)
			return
		data.bbarhs[mode].append([])
		data.bcolors[mode].append([])
		data.bbarhs[mode][len(data.bbarhs[mode]) - 1].append((start, length))
		data.bcolors[mode][len(data.bcolors[mode]) - 1].append(color)

	for k, v in sorted_maps:
		if v.start == 0 or v.length == 0:
			print('Warning: incomplete %s(%s) %d:%d'
					% (modes[mode], k, v.start, v.length))
		if data.accum[mode] / v.length > 100:
			other += v.length
			continue

		if v.async == 1:
			k += '(async)'
		if v.info:
			k += '(%s)' % v.info
		color = get_color()
		add_frac(k, v.length, color)
		add_bbarh(v.start, v.length, color)

	if other > 0:
		add_frac('[Others]', other, 'w')

	p1.pie(data.pfracs[mode], labels = data.plables[mode], colors = data.pcolors[mode],
			autopct = '%1.1f%%', labeldistance = 0.9, shadow = True)
	p1.set_title('%s:%s[%d] devs_total=%.1f, ftrace_calc=%.1f, sysfs_read=%dms'
			% (data.fname, modes[mode], data.count[mode],
			data.accum[mode], data.full[mode][1], data.real[mode]))
	i = 1
	for bbarh, bcolor in zip(data.bbarhs[mode], data.bcolors[mode]):
		p2.broken_barh(bbarh, (i, 1), facecolors = bcolor)
		i += 1

	p2.set_xlim(data.full[mode][0], data.full[mode][1])
	p2.set_ylim(0, i)

	def ex_bbar(plt, item, text, color, y, h, align):
		text = '%s:%.1f' % (text, item[1] - item[0])
		ha = 'left' if align == 0 else 'right'
		x = item[0] if align == 0 else item[1]
		print '%s - %s - (%f, %f)' % (text, color, item[0], item[1])
		plt.broken_barh([(item[0], item[1] - item[0])], (y, h),
				alpha = 0.5, facecolors = color)
		plt.annotate(text, xy = (x, h), xytext = (x, h),
				ha = ha, va = 'baseline')

	ex_bbar(p2, data.key[mode],   'key',   'green',  0, 1,    0)
	ex_bbar(p2, data.devs[mode],  'devs',  'yellow', 0, 0.75, 1)
	ex_bbar(p2, data.disp[mode],  'disp',  'blue',   0, 0.5,  1)
	ex_bbar(p2, data.touch[mode], 'touch', 'red',    0, 0.25, 0)

# main func
fig = plt.figure(figsize=(24,12))
p1 = fig.add_subplot(2, 2, 1)
p2 = fig.add_subplot(2, 2, 2)
p3 = fig.add_subplot(2, 2, 3)
p4 = fig.add_subplot(2, 2, 4)
data = Data()
parse_cmd()
read_data()
norm_data()
draw_piebar(p1, p2, SUSPEND)
draw_piebar(p3, p4, RESUME)
plt.savefig('%s.png' % data.fname)
plt.show()

