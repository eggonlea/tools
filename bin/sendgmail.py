#!/usr/bin/python

import os
import sys
import getopt
import smtplib
from email.mime.text import MIMEText as text

def send_email(to_address, subject, body):
	print "Sending email..."
	smtp_server = 'smtp.gmail.com'
	smtp_port= 587
	smtp_user=os.getenv('SMTP_USER')
	smtp_password=os.getenv('SMTP_PASS')
	from_address='"Myself"<' + smtp_user + '>'

	#---------compose-------
	msg = text(body)
	msg['Subject'] = subject
	msg['From'] = from_address
	msg['To'] = to_address
	print msg

	#---------send-------
	server = smtplib.SMTP(smtp_server, smtp_port)
	server.ehlo()
	server.starttls()
	server.login(smtp_user, smtp_password)
	server.sendmail(from_address, to_address, msg.as_string())
	server.quit()
	print "Done"
 
if __name__ == '__main__':
	to_address=os.getenv('SMTP_USER')
	subject = ''
	body = ''
	try:
		opts, args = getopt.getopt(sys.argv[1:],"ht:s:m:")
	except getopt.GetoptError:
		print 'sendgmail.py [-h] -t <TO> -s <SUBJECT> -m<MSG>'
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			print 'sendgmail.py [-h] -t <TO> -s <SUBJECT> -m<MSG>'
			sys.exit()
		elif opt == '-t':
			to_address = arg
		elif opt == '-s':
			subject = arg
		elif opt == '-m':
			body = arg

	send_email(to_address, subject, body)
