#!/usr/bin/python

import csv
import os
import re
import sys

wtfs = []


class WtfStack:
  def __init__(self, pid, stack):
    self.count = 1
    self.pid = pid
    self.stack = stack.copy()


def usage():
  print('Usage: %s [file|dir]' % sys.argv[0])
  sys.exit(1)


def add_wtf(pid, stack):
  global wtfs

  print('add: %d %s' % (pid, stack))
  for w in wtfs:
    if w.pid == pid and w.stack == stack:
      w.count += 1
      print('old stack: %d' % w.count)
      return
  w = WtfStack(pid, stack)
  wtfs.append(w)
  print('new stack: %d' % len(wtfs))


def traverse(path):
  print('Traversing [%s]...' % path)
  for root, dirs, files in os.walk(path, followlinks=True):
    for file in files:
      fname = os.path.join(root, file)
      parse(fname)


def parse(path):
  detected = False
  pid = 0
  stack = []

  print('Parsing [%s]...' % path)
  with open(path, 'r', encoding='ISO-8859-1') as f:
    for line in f:
      m = re.match(
          r'\d+-\d+ \d+:\d+:\d+.\d+.* (\d+)\s+\d+ E \S+\s*:\s*at (android.util.Log.wtfStack.*)',
          line.strip())
      if m:
        if detected:
          add_wtf(pid, stack)
          pid = int(m.group(1))
          stack.clear()
          stack.append(m.group(2))
        else:
          detected = True
          pid = int(m.group(1))
          stack.append(m.group(2))
      elif detected:
        m = re.match(
            r'\d+-\d+ \d+:\d+:\d+.\d+.* (\d+)\s+\d+ E \S+\s*:\s*at (.*)',
            line.strip())
        if m:
          if pid != int(m.group(1)):
            print('Warning: pid mismatch: %d != %d' % (pid, m.group(1)))
          stack.append(m.group(2))
        else:
          detected = False
          add_wtf(pid, stack)
          pid = 0
          stack.clear()


def main():
  global wtfs

  path = '.'
  argc = len(sys.argv)
  if argc > 2:
    usage()
  elif argc == 2:
    path = sys.argv[1]

  traverse(path)
  wtfs.sort(key=lambda x: x.count, reverse=True)
  n = 0
  with open('out.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['total', 'count', 'pid', 'stack'])
    for w in wtfs:
      n += w.count
      stack = '\n'.join(w.stack)
      row = [n, w.count, w.pid, stack]
      print(row)
      writer.writerow(row)
  print('Total wtfStack: %d (%d)' % (len(wtfs), n))


if __name__ == '__main__':
  main()
