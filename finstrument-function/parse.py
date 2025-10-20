#!/usr/bin/python

import os
import sys
import re
import subprocess

def usage():
	print 'Usage: %s <exe> <exe.log> <basename>' % sys.argv[0]
	sys.exit(1)

def parse_cmd():
	global fexe
	global fin
	global fout
	global basename

	if len(sys.argv) == 4:
		fexe = sys.argv[1]
		fin = sys.argv[2]
		basename = sys.argv[3]
		fout = '%s.out' % fexe
	else:
		usage()

def parse_addr():
	global fexe
	global fin
	global fout
	global flst

	try:
		f = open(fin)
		out = open(fout, 'w')
	except IOERROR as e:
		print 'failed to open "{0}":({1}) {2}'.format(log, e.errno, e.strerror)

	funcs = {}
	for line in f:
		addrs = re.findall('0x[0-9A-Fa-f]+', line)
		for addr in addrs:
			if addr not in funcs:
				func = addr2func(addr)
				funcs[addr] = func
				print '%s %s' % (addr, func)
			else:
				func = funcs[addr]
			line = re.sub(addr, func, line)
		out.write(line)

	f.close()
	out.close()

def addr2func(addr):
	global fexe
	global basename

	cmd = ['addr2line', '-p', '-f', '-e', fexe, addr]
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
	func = p.stdout.readline().strip()
	func = re.sub(r' at ', r' ', func)
	func = re.sub(basename, '', func)

	return func

if __name__ == '__main__':
	parse_cmd()
	parse_addr()
