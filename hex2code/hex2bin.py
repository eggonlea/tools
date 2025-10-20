#!/usr/bin/python

import sys
import struct

for line in sys.stdin:
	words = line.split()
	for word in words:
		sys.stdout.write(struct.pack('I', int(word, 16)))

