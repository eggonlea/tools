#!/usr/bin/python

# sudo apt-get install python-matplotlib

import sys
import re
import operator
import subprocess
from datetime import datetime
import matplotlib.pyplot as plt
from matplotlib.widgets import Button
import pdb

class Plotter:
	def __init__(self):
		self.fig = plt.figure(1, figsize=(16,12))
		self.ax = self.fig.add_axes([0.05, 0.05, 0.9, 0.9],
			xscale='linear', xlabel='Sample (per 100ms)',
			yscale='linear', ylabel='Frequency')
		self.reset_lines()
		self.line_cpu, = self.ax.plot(self.x, self.cpu, 'g', label='CPU')
		self.line_acpu, = self.ax.plot(self.x, self.acpu, 'b--', label='AVG CPU')
		self.line_dvfs, = self.ax.plot(self.x, self.dvfs, 'y', label='DVFS')
		self.line_advfs, = self.ax.plot(self.x, self.advfs, 'r--', label='AVG DVFS')
		self.ax.legend()

		bax = self.fig.add_axes([0.05, 0.9, 0.05, 0.05])
		self.breset = Button(bax, 'Reset')
		self.breset.on_clicked(self.start_timer)

		bax = self.fig.add_axes([0.1, 0.9, 0.05, 0.05])
		self.bsave = Button(bax, 'Snapshot')
		self.bsave.on_clicked(self.save_snapshot)
	
		bax = self.fig.add_axes([0.15, 0.9, 0.05, 0.05])
		self.bpause = Button(bax, 'Pause')
		self.bpause.on_clicked(self.pause_timer)
	
		self.draw_lines()
		self.timer = self.fig.canvas.new_timer(interval=100)
		self.timer.add_callback(self.draw_lines)
		self.timer.start()

	def start_timer(self, event=None):
		#pdb.set_trace()
		self.reset_lines()
		self.timer.start()

	def pause_timer(self, event=None):
		#pdb.set_trace()
		self.timer.stop()

	def save_snapshot(self, event=None):
		plt.savefig('snapshot_%d.png' % self.count)

	def reset_lines(self, event=None):
		self.count = 0
		self.x = []
		self.cpu = []
		self.scpu = 0.0
		self.acpu = []
		self.dvfs = []
		self.sdvfs = 0.0
		self.advfs = []

	def draw_lines(self):
		global count, x
		global cpu, scpu, acpu
		global dvfs, sdvfs, advfs
	
		self.count += 1
		self.x.append(self.count)
	
		cmd = ['adb', 'shell', 'cat /d/clock/cpu/rate']
		p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
		f = p.stdout
		vcpu = float(f.readline()) / 1000000
		self.cpu.append(vcpu)
		self.scpu += vcpu
		self.acpu.append(self.scpu/self.count)
		p.wait()
	
		cmd = ['adb', 'shell', 'cat /d/clock/dfll_cpu/cl_dvfs/monitor']
		p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
		f = p.stdout
		vdvfs = float(f.readline()) / 1000000
		self.dvfs.append(vdvfs)
		self.sdvfs += vdvfs
		self.advfs.append(self.sdvfs/self.count)
		p.wait()
	
		self.line_cpu.set_data(self.x, self.cpu)
		self.line_acpu.set_data(self.x, self.acpu)
		self.line_dvfs.set_data(self.x, self.dvfs)
		self.line_advfs.set_data(self.x, self.advfs)
		self.ax.set_title('CPU:%.1f/%.1f DVFS %.1f/%.1f (%.1f%%)'
			 % (vcpu, self.scpu/self.count, 
				vdvfs, self.sdvfs/self.count,
				(self.sdvfs/self.scpu - 1)*100))
		self.ax.relim()
		self.ax.autoscale_view()
		self.fig.canvas.draw_idle()

plotter = Plotter()
plt.show()
