#!/usr/bin/python

# apt install python-is-python3 python3-pil python3-tk python3-pil.imagetk

import threading
import tkinter
from PIL import ImageDraw, Image, ImageTk
import sys
import os

class AndroidDesktop:
	def __init__(self):
		self.lock = threading.Lock()
		self.width = 0
		self.height = 0
		self.w2 = 0
		self.h2 = 0
		self.resize = 3
		self.x = 0
		self.y = 0
		self.image = None
		self.image_tk = None
		self.window = tkinter.Tk(className="android")
		self.canvas = tkinter.Canvas(self.window)
		self.image_canvas = None
		self.afterid = None
		self.canvas.bind("<Button-1>", self.down_callback)
		self.canvas.bind("<ButtonRelease-1>", self.up_callback)
		self.canvas.pack()

	def reinit(self):
		self.width = self.image.size[0]
		self.height = self.image.size[1]
		self.w2 = int(self.width / self.resize)
		self.h2 = int(self.height / self.resize)
		print("(%d, %d) ==> (%d, %d)" % (self.width, self.height, self.w2, self.h2))
		self.window.geometry("%dx%d" % (self.w2, self.h2))
		self.canvas.config(width = self.w2, height=self.h2)

	def read_pic(self):
		with self.lock:
			os.system("adb shell screencap -p /data/android.png")
			os.system("adb pull /data/android.png /tmp/android.png")
			self.image = Image.open("/tmp/android.png")

	def draw_pic(self):
		if self.afterid != None:
			self.canvas.after_cancel(self.afterid)
		self.read_pic()
		if self.width != self.image.size[0] or self.height != self.image.size[1]:
			self.reinit()
		self.image = self.image.resize((self.w2, self.h2), Image.ANTIALIAS)
		self.image_tk = ImageTk.PhotoImage(self.image)
		if self.image_canvas == None:
			self.image_canvas = self.canvas.create_image(0, 0, anchor=tkinter.NW, image=self.image_tk)
		else:
			self.canvas.itemconfig(self.image_canvas, image=self.image_tk)
		self.afterid = self.canvas.after(500, self.draw_pic)

	def down_callback(self, event):
		x = event.x * self.resize
		y = event.y * self.resize
		print("down at: ", x, y)
		self.x = x
		self.y = y

	def up_callback(self, event):
		with self.lock:
			x = event.x * self.resize
			y = event.y * self.resize
			print("up at: ", x, y)
			if x == self.x and y == self.y:
				print("click")
				os.system("adb shell input tap %d %d" % (x, y))
			else:
				print("swipe")
				os.system("adb shell input swipe %d %d %d %d" % (self.x, self.y, x, y))

ad = AndroidDesktop()
ad.draw_pic()
tkinter.mainloop()

