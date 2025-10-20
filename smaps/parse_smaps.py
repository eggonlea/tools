#!/usr/bin/python

import os
import sys
import re
import operator
import locale

class Smap:
	def __init__(self, name = None):
		self.name = name
		self.total = {}

class Comm:
	def __init__(self, pid = None, comm = None):
		self.pid = pid
		self.comm = comm
		self.total = {}

class Cate:
	def __init__(self, name = None):
		self.name = name
		self.total = {}

def usage():
	print 'Usage: %s [smaps.dump]' % sys.argv[0]
	sys.exit(1)

def parse_cmd():
	global fname
	global is_show_anon_mmap
	global is_show_non_anon_ashmem
	global is_show_deleted_mmap

	# turn any on for detailed output
	is_show_anon_mmap = False
	is_show_non_anon_ashmem = False
	is_show_deleted_mmap = False

	if len(sys.argv) == 1:
		fname = 'smaps.dump'
	elif len(sys.argv) == 2:
		fname = sys.argv[1]
	else:
		usage()

def add_item(key, val, dic):
	if key not in dic:
		dic[key] = val
	else:
		dic[key] += val

# file-backed mmap with Anonymous pages
def show_anon_mmap(comm, cur_map, line):
	if(is_show_anon_mmap
	and cur_map['Cate'].find('mmap') >= 0
	and cur_map['Uss'] > 0
	and (cur_map['Anon'] > 0 or cur_map['Private_Dirty'] > 0)):
		print 'Found file-backed mmap including Anonymous pages at line %d' % line
		print 'pid=%d comm=%s' % (comm.pid, comm.comm)
		for key in cur_map:
			print '\t%s = %s' % (key, cur_map[key])

# Ashmem without Anonymous pages
def show_non_anon_ashmem(comm, cur_map, line):
	if(is_show_non_anon_ashmem
	and cur_map['Cate'] == 'Ashmem'
	and cur_map['Uss'] > 0
	and cur_map['Anon'] == 0):
		print 'Found Ashmem mapping without Anonymous pages at line %d' % line
		print 'pid=%d comm=%s' % (comm.pid, comm.comm)
		for key in cur_map:
			print '\t%s = %s' % (key, cur_map[key])

def read_data():
	global smaps
	global comms
	global cates

	try:
		f = open(fname)
	except IOError as e:
		print 'failed to open "{0}":({1}) {2}'.format(fname, e.errno, e.strerror)

	smaps = {}
	comms = []
	cates = {}
	lines = 0
	for line in f:
		lines += 1

		# A new process
		m = re.match('### /proc/(\d+)/comm \[(\S*)\] ###', line.strip())
		if m:
			pid = int(m.group(1), 10)
			comm = Comm(pid, m.group(2))
			comms.append(comm)
			continue

		# A new mapping
		m = re.match('\w+-\w+\s....\s\w+\s\w+:\w+\s\w+\s*(.*)', line.strip())
		if m:
			name = m.group(1) if len(m.group(1)) > 0 else "[noname]"
			cur_map = {'Name' : name} # temp variable to calculat P-Anon

			if name not in smaps:
				smap = Smap(name)
				smaps[name] = smap
			else:
				smap = smaps[name]

			name = get_cate(name)
			cur_map['Cate'] = name # temp variable to calculat P-Anon
			if name not in cates:
				cate = Cate(name)
				cates[name] = cate
			else:
				cate = cates[name]

			continue

		# A mapping item
		m = re.match('(\w+):\s+(\d+)\skB', line.strip())
		if m:
			key = m.group(1)
			size = int(m.group(2), 10)
			if key == 'Anonymous':
				key = 'Anon'
			add_item(key, size, smap.total)
			add_item(key, size, comm.total)
			add_item(key, size, cate.total)
			add_item(key, size, cur_map)

			# calculate USS
			if key[0:7] == 'Private':
				add_item('Uss', size, smap.total)
				add_item('Uss', size, comm.total)
				add_item('Uss', size, cate.total)
				add_item('Uss', size, cur_map)

			# calculate Anon
			if key == 'Anon':
				# rough estimation of P-Anon
				if cur_map['Anon'] == 0 or cur_map['Rss'] == cur_map['Uss']:
					size = max(cur_map['Anon'], cur_map['Private_Dirty'])
				else:
					uanon = min(cur_map['Anon'], cur_map['Private_Dirty'])
					panon = cur_map['Anon'] - uanon
					ratio = (cur_map['Pss'] - cur_map['Uss']) / (cur_map['Rss'] - cur_map['Uss'])
					size = panon * ratio + uanon

				add_item('P-Anon', size, smap.total)
				add_item('P-Anon', size, comm.total)
				add_item('P-Anon', size, cate.total)
				add_item('P-Anon', size, cur_map)

		# finish a mapping item
		m = re.match('VmFlags: .*', line.strip())
		if m:
			show_anon_mmap(comm, cur_map, lines)
			show_non_anon_ashmem(comm, cur_map, lines)

	f.close()

def sort_smap(key = 'Pss'):
	global smaps

	def get_key(item):
		return item.total[key]
	
	smaps = [smaps[s] for s in smaps]
	smaps.sort(reverse = True, key = get_key)

def sort_comm(key = 'Pss'):
	def get_key(item):
		if key in item.total:
			return item.total[key]
		else:
			return 0

	comms.sort(reverse = True, key = get_key)

def sort_cate(key = 'Pss'):
	global cates

	def get_key(item):
		return item.total[key]
	
	cates = [cates[c] for c in cates]
	cates.sort(reverse = True, key = get_key)

def show_smap():
	print
	print '%3s  %s  %s' % ('#', '  '.join(['%10s' % s for s in cols]), 'Name')
	print '=' * 80
	i = 0
	for smap in smaps:
		print '%3d  %s  %s' % (i, '  '.join([format(smap.total[s], '10,d') for s in cols]), smap.name)
		i += 1
	print

def show_comm():
	print
	print '%3s  %s  %s' % ('#', '  '.join(['%10s' % s for s in cols]), 'Name #pid')
	print '=' * 80
	i = 0
	for comm in comms:
		if len(comm.total) == 0:
			continue
		print '%3d  %s  %s #%d' % (i, '  '.join([format(comm.total[s], '10,d') for s in cols]), comm.comm, comm.pid)
		i += 1
	print

def show_cate():
	total = {}
	mmap = {}
	anon = {}
	print
	print '%3s  %s  %s' % ('#', '  '.join(['%10s' % s for s in cols]), 'Name')
	print '=' * 80
	i = 0
	for cate in cates:
		print '%3d  %s  %s' % (i, '  '.join([format(cate.total[s], '10,d') for s in cols]), cate.name)
		for s in cols:
			add_item(s, cate.total[s], total)
			if cate.name.find('mmap') == -1:
				add_item(s, cate.total[s], anon)
			else:
				add_item(s, cate.total[s], mmap)
		i += 1
	print '-' * 80
	print '%3d  %s  %s' % (i, '  '.join([format(mmap[s], '10,d') for s in cols]), 'Total Mmap')
	print '%3d  %s  %s' % (i, '  '.join([format(anon[s], '10,d') for s in cols]), 'Total Anon')
	print '%3d  %s  %s' % (i, '  '.join([format(total[s], '10,d') for s in cols]), 'Total')
	print

def get_cate(name):
	suffix = ''
	if is_show_deleted_mmap and name[-9:] == '(deleted)':
		suffix = ' (deleted)'
	if name == '[heap]':
		return 'Native heap' + suffix
	if(name.find('/dev/ashmem/dalvik-alloc space') == 0
	or name.find('/dev/ashmem/dalvik-main space') == 0
	or name.find('/dev/ashmem/dalvik-non moving space') == 0
	or name.find('/dev/ashmem/dalvik-large object space') == 0):
		return 'Dalvik' + suffix
	if name[:19] == '/dev/ashmem/dalvik-':
		return 'Dalvik Other' + suffix
	if name == '/dev/ashmem/CursorWindow':
		return 'Cursor' + suffix
	if name == '/dev/ashmem/libc malloc' \
	or name == '[anon:libc_malloc]':
		return 'Naive malloc' + suffix
	if name[:11] == '/dev/ashmem':
		return 'Ashmem' + suffix
	if name[:6] == '[stack':
		return 'Stack' + suffix
	if name[:5] == '/dev/':
		return 'Other dev' + suffix
	if name[-3:] == '.so':
		return '.so mmap' + suffix
	if name[-4:] == '.jar':
		return '.jar mmap' + suffix
	if name[-4:] == '.apk':
		return '.apk mmap' + suffix
	if name[-4:] == '.ttf':
		return '.ttf mmap' + suffix
	if name[-4:] == '.dex' \
	or name[-5:] == '.odex':
		return '.dex mmap' + suffix
	if name[-4:] == '.oat':
		return 'code mmap .oat' + suffix
	if name[-4:] == '.art':
		return 'image mmap .art' + suffix
	if name[:6] == '[anon:':
		return 'Unknown anon' + suffix
	if name[:11] == 'anon_inode:':
		return 'NvMAP mapped' + suffix
	if name == '[noname]':
		return 'Unknown' + suffix

	return 'Other mmap' + suffix

# main func
parse_cmd()
read_data()

sort_smap()
sort_comm()
sort_cate()

cols = ['Size', 'Rss', 'Pss', 'Uss', 'Anon', 'P-Anon']
show_smap()
show_comm()
show_cate()

