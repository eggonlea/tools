#!/usr/bin/python

import sys
import re
import operator
import subprocess
from datetime import datetime
import matplotlib.pyplot as plt
from matplotlib.widgets import Button
import itertools
#import pdb

K = 1024
M = K * K
G = M * K

class Memmap:
  def __init__(self):
    self.x = []
    self.mems = []
    self.line = None

class Plotter:
  def __init__(self):
    self.mode = 0
    self.parse_args()

    self.total = 0
    self.fig = plt.figure(1, figsize=(32,12))
    self.fig.canvas.manager.set_window_title('maps')
    self.ax1 = self.fig.add_axes([0.05, 0.05, 0.5, 0.9],
      xscale='linear', xlabel='Sample (per 1s)',
      yscale='linear', ylabel='MB')
    self.ax2 = self.fig.add_subplot(1,2,2, aspect=1)
    #self.fig.tight_layout()

    self.reset_lines()

    bax = self.fig.add_axes([0.05, 0.9, 0.05, 0.05])
    self.bsave = Button(bax, 'Sanpshot')
    self.bsave.on_clicked(self.save_snapshot)

    bax = self.fig.add_axes([0.1, 0.9, 0.05, 0.05])
    self.breset = Button(bax, 'Reset')
    self.breset.on_clicked(self.reset_lines)

    bax = self.fig.add_axes([0.15, 0.9, 0.05, 0.05])
    self.bpause = Button(bax, 'Pause')
    self.bpause.on_clicked(self.toggle_timer)

    self.update_plot()

    self.timer = self.fig.canvas.new_timer(interval=1000)
    self.timer.add_callback(self.update_plot)
    self.timer.start()
    self.running = True

  def toggle_timer(self, event=None):
    #pdb.set_trace()
    if self.running:
      self.timer.stop()
      self.bpause.label.set_text('Start')
      self.running = False
    else:
      self.timer.start()
      self.bpause.label.set_text('Pause')
      self.running = False
      self.running = True

  def save_snapshot(self, event=None):
    plt.savefig('snapshot_%d.png' % self.count)

  def reset_lines(self, event=None):
    self.count = 0
    self.memmaps = {}
    #self.ax1.lines = []
    self.rainbowpool = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet']
    self.rainbow = itertools.cycle(self.rainbowpool)
    self.k2color = {}

  def draw_lines(self):
    for k,memmap in self.memmaps.items():
      memmap.line.set_data(memmap.x, memmap.mems)
    #self.ax1.legend()
    self.ax1.relim()
    self.ax1.autoscale_view()

  def mem2str(self, n):
    if n > G:
      s = '%dG' % (n / G)
    elif n > M:
      s = '%dM' % (n / M)
    elif n > K:
      s = '%dK' % (n / K)
    else:
      s = '%dB' % (n)
    return s

  def parse_args(self):
    if len(sys.argv) == 3:
      if sys.argv[1] == '-f':
        self.mode = 1
        self.fname = sys.argv[2]
      elif sys.argv[1] == '-p':
        self.mode = 2
        self.pid = int(sys.argv[2])
        cmd = ['adb', 'shell', 'cat /proc/%d/cmdline' % self.pid]
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        self.fname = '%s[%d]' % (p.stdout.read().decode().rstrip('\0'), self.pid)
        p.wait()

    if self.mode == 0:
      print('Usage: %s <-f input_file | -p pid>' % sys.argv[0])
      sys.exit(1)

  def read_data(self):
    # read /proc/<pid>/maps line by line
    # 70d5b000-70e58000 rw-p 00000000 00:00 0          [stack:5286]
    self.lables = []
    self.fracs = []
    self.colors = []

    if self.mode == 1:
      f = open(self.fname)
    elif self.mode == 2:
      cmd = ['adb', 'shell', 'cat /proc/%d/maps' % self.pid]
      p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
      f = p.stdout

    maps = {}
    self.total = 0
    for line in f:
      m = re.match('([0-9a-f]+)-([0-9a-f]+) .... [0-9a-f]+ [0-9a-f]+:[0-9a-f]+ [0-9a-f]+\s*(.*)', line.strip().decode())
      if not m:
        continue
      start = m.group(1)
      end = m.group(2)
      name = m.group(3)
      length = int(end, 16) - int(start, 16)
      self.total += length
      if name == "":
        name = "[UNKNOWN]"
      if name in maps:
        maps[name] += length
      else:
        maps[name] = length

    if self.mode == 1:
      f.close()
    elif self.mode == 2:
      p.wait()

    sorted_maps = sorted(maps.items(), key=operator.itemgetter(1), reverse=True)
    other = 0
    for k, v in sorted_maps:
      if self.total / v > 100:
        other += v
        continue
      self.add_memmap(k, v)

    if other > 0:
      self.add_memmap('[Others]', other)

    if self.count == 0:
      print('\n'.join(self.lables))
    print('%d (KB): %s' % (self.count, ' '.join(str(i / K) for i in self.fracs)))

    self.count += 1

  def add_memmap(self, k, v):
    if k not in self.memmaps:
      mm = Memmap()
      self.k2color[k] = next(self.rainbow)
      mm.line, = self.ax1.plot([], [], self.k2color[k], label=k)
      self.memmaps[k] = mm
    mm = self.memmaps[k]
    mm.x.append(self.count)
    mm.mems.append(v / M)

    self.lables.append('%s:%s' % (self.mem2str(v), k))
    self.fracs.append(v)
    self.colors.append(self.k2color[k])

  def draw_pie(self):
    self.ax2.clear()
    self.ax2.pie(self.fracs, labels=self.lables, colors=self.colors,
      autopct='%1.1f%%', shadow=True)
    plt.title('%s:%s' % (self.mem2str(self.total), self.fname))

  def update_plot(self):
    self.read_data()
    self.draw_lines()
    self.draw_pie()
    #self.fig.canvas.draw()
    self.fig.canvas.draw_idle()

plotter = Plotter()
plt.show()
