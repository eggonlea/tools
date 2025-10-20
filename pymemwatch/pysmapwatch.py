#!/usr/bin/python

import sys
import re
import operator
import subprocess
from datetime import datetime
import matplotlib.pyplot as plt
from matplotlib.widgets import Button
import itertools
import pdb

K = 1024
M = K * K
G = M * K

class Smap:
  def __init__(self, name=None):
    self.mems = {}
    self.name = name
  def __getitem__(self, item):
    return self.mems[item]

class Plotter:
  def __init__(self):
    self.mode = 0
    self.parse_args()

    self.total = {}
    self.fig = plt.figure(1, figsize=(32,12))
    self.fig.canvas.manager.set_window_title('smaps')
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
    self.x = {}
    self.mems = {}
    self.lines = {}
    self.xswap = []
    self.memswap = []

    #self.ax1.lines = []
    self.lineswap, = self.ax1.plot([], [], 'bo', label='Swap')
    self.memtypes = ['Pss', 'Rss', 'Uss', 'Anon']
    self.linestyles = {
      'Pss' : '-',
      'Rss' : ':',
      'Uss' : '-.',
      'Anon': '--',
      'Swap': 'o'}
    self.rainbowpool = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet']
    self.rainbow = itertools.cycle(self.rainbowpool)
    self.k2color = {}

  def draw_lines(self):
    self.lineswap.set_data(self.xswap, self.memswap)
    for k, lines in self.lines.items():
      for memtype, line in lines.items():
        #pdb.set_trace()
        line.set_data(self.x[k], self.mems[k][memtype])
    #self.ax1.legend()
    self.ax1.relim()
    self.ax1.autoscale_view()

  def mem2str(self, n):
    if n > M:
      s = '%dG' % (n / M)
    elif n > K:
      s = '%dM' % (n / K)
    else:
      s = '%dK' % (n)
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
    # read /proc/<pid>/smaps line by line
    # 12c00000-12e13000 rw-p 00000000 00:04 14728                              /dev/ashmem/dalvik-main space (deleted)
    self.lables = []
    self.fracs = []
    self.colors = []

    if self.mode == 1:
      f = open(self.fname, 'r')
    elif self.mode == 2:
      cmd = ['adb', 'shell', 'cat /proc/%d/smaps' % self.pid]
      p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
      f = p.stdout

    swap = 0
    smaps = {}
    self.total = {}
    for line in f:
      # A new mapping
      m = re.match('\w+-\w+\s....\s\w+\s\w+:\w+\s\w+\s*(.*)', line.strip().decode())
      if m:
        name = m.group(1) if len(m.group(1)) > 0 else "[UNKNOWN]"

        if name not in smaps:
          smap = Smap(name)
          smaps[name] = smap
        else:
          smap = smaps[name]

        continue

      # A mapping item
      m = re.match('(\w+):\s+(\d+)\skB', line.strip().decode())
      if m:
        key = m.group(1)
        size = int(m.group(2), 10)
        if key == 'Anonymous':
          key = 'Anon'
        elif key[0:7] == 'Private':
          key = 'Uss'
        elif key == 'Pss' or key == 'Rss':
          pass
        elif key == 'Swap':
          swap += size
          continue
        else:
          continue

        if key not in smap.mems:
          smap.mems[key] = size
        else:
          smap.mems[key] += size

        if key not in self.total:
          self.total[key] = size
        else:
          self.total[key] += size

        continue

    if self.mode == 1:
      f.close()
    elif self.mode == 2:
      p.wait()

    if swap > 0:
      self.xswap.append(self.count)
      self.memswap.append(swap / K)
    for memtype in self.memtypes:
      self.process_data(smaps, memtype)

    self.count += 1

  def process_data(self, smaps, memtype):
    sorted_smaps = sorted(smaps.items(), key=lambda v: v[1].mems[memtype], reverse=True)
    other = {}
    for k, v in sorted_smaps:
      if v['Pss'] == 0 or self.total['Pss'] / v['Pss'] > 100:
        if memtype not in other:
          other[memtype] = v[memtype]
        else:
          other[memtype] += v[memtype]
        continue

      self.add_smemmap(k, v[memtype], memtype)

    if other[memtype] > 0:
      self.add_smemmap('[Others]', other[memtype], memtype)

    if memtype == 'Pss':
      if self.count == 0:
        print('\n'.join(self.lables))
      else:
        print('%d (KB): %s' % (self.count, ' '.join(str(i) for i in self.fracs)))

  def add_smemmap(self, k, v, memtype):
    if k not in self.mems:
      self.x[k] = []
      self.mems[k] = {}
      self.lines[k] = {}
      color = next(self.rainbow)
      self.k2color[k] = color

    if memtype not in self.mems[k]:
      self.mems[k][memtype] = []
      style = self.linestyles[memtype]
      line, = self.ax1.plot([], [], color=self.k2color[k],
        linestyle=style, label='%s_%s' % (k, memtype))
      self.lines[k][memtype] = line

    self.mems[k][memtype].append(v / K)

    if memtype == 'Pss':
      self.x[k].append(self.count)
      self.lables.append('%s:%s' % (self.mem2str(v), k))
      self.fracs.append(v)
      self.colors.append(self.k2color[k])

  def draw_pie(self):
    self.ax2.clear()
    self.ax2.pie(self.fracs, labels=self.lables, colors=self.colors,
      autopct='%1.1f%%', shadow=True)
    plt.title('%s:%s' % (self.mem2str(self.total['Pss']), self.fname))

  def update_plot(self):
    self.read_data()
    self.draw_lines()
    self.draw_pie()
    #self.fig.canvas.draw()
    self.fig.canvas.draw_idle()

plotter = Plotter()
plt.show()
