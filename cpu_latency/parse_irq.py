import argparse

parser = argparse.ArgumentParser('parse IRQ off kernel function trace output')
parser.add_argument('filename', type=str)
args = parser.parse_args()

start_line = 0
start_time = 0
end_time = 0
line_num = 0
task = ""

irq_list = []

with open(args.filename) as f:
	for line in f:
		line_num += 1
		pline = line.split()

		if pline[4][:-1] == 'irq_handler_entry':
			task = pline[0]
			start_line = line_num
			start_time = float(pline[3][:-1])
		elif pline[4][:-1] == 'irq_handler_exit':
			end_time = float(pline[3][:-1])
			irq_list.append((end_time - start_time, start_line))

irq_list.sort(reverse=True)

print "{0:20}  {1}".format("time(s)", "line")
for item in irq_list:
	print item
