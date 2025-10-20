#!/usr/bin/python

import sys
import re

if len(sys.argv) != 3:
        print "Usage: %s <old> </proc/stat>" % sys.argv[0]
	sys.exit(1)

old_stat = open(sys.argv[1], 'r')
new_stat = open(sys.argv[2], 'r')

while True:
	old_line = old_stat.readline().strip()
	new_line = new_stat.readline().strip()
	if old_line.startswith("cpu") and new_line.startswith("cpu"):
		old_data = old_line.split()
		new_data = new_line.split()
		if old_data[0] != new_data[0] or len(old_data) != 11 or len(new_data) != 11:
			print "Invalid /proc/stat cpu data!"
			sys.exit(1)
		old_all = 0
		for i in range(1, 10):
			old_all += int(old_data[i])
		new_all = 0
		for i in range(1, 10):
			new_all += int(new_data[i])

		if new_data[0] == "cpu":
			name = "cpu*"
		else:
			name = new_data[0]
		delta = new_all - old_all
		if delta == 0:
			print "%s U/S/W: - - -" % (name)
			continue
		user = int(new_data[1]) - int(old_data[1])
		nice = int(new_data[2]) - int(old_data[2])
		sys = int(new_data[3]) - int(old_data[3])
		iow = int(new_data[5]) - int(old_data[5])

		print "%s U/S/W: %d %d %d" % (name,
						 (user + nice) * 100 / delta,
						 sys * 100 / delta,
						 iow * 100 / delta)
	else:
		break
#end
