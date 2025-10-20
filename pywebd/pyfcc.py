#!/usr/bin/python

import sys
import re
import time
import urllib
import urllib2
import requests
import smtplib
from email.mime.text import MIMEText as text

def is_in_pool(key, status = None):
	pool = [('AI6QW',	'Active'),
		('0007314421',	'Granted'),
		('0007315253',	'Dismissed'),
		('0007342081',	'Dismissed'),
		('0007373194',	'Dismissed'),
		('0007404015',	'Dismissed'),
		('0007404953',	'Dismissed'),
		('0007435420',	'Dismissed'),
		('0007449679',	'Granted'),
		('0007452074',	'Granted'),
		('0007464968',	'Pending'),
		('0007468391',	'Pending')]
	for i in pool:
		if i[0] == key and (i[1] == status or None == status):
			return True
	return False

def search_fccapplication():
	print 'Checking FCC application...'
	url = 'http://wireless2.fcc.gov/UlsApp/ApplicationSearch/ApplSearchController'
	form = {
		'basicSearchType' : 'basicSearchFrn',
		'basicSearchTerm' : '0025312828',
		'x' : 1,
		'y' : 1,
		'exactMatchInd' : 'Y',
		'jsValidated' : 'true',
		'currentPage' : 'searchAppl.jsp',
		'actionElement' : 'actionApplicationSearch' }
	headers = { 'Referer' : 'http://wireless2.fcc.gov/UlsApp/ApplicationSearch/searchAppl.jsp' }
	res = requests.post(url, headers=headers, data=form)
	return res.text

def search_fcclicense():
	print 'Checking FCC license...'
	url = 'http://wireless2.fcc.gov/UlsApp/UlsSearch/results.jsp'
	form = {
		'fiUlsSearchByType' : 'uls_l_frn',
		'fiUlsSearchByValue' : '0025312828',
		'x' : 1,
		'y' : 1,
		'fiUlsExactMatchInd' : 'Y',
		'hiddenForm' : 'hiddenForm',
		'jsValidated' : 'true' }
	headers = { 'Referer' : 'http://wireless2.fcc.gov/UlsApp/UlsSearch/searchLicense.jsp' }
	res = requests.post(url, headers=headers, data=form)
	return res.text

def search_arrl():
	print 'Checking ARRL callsign...'
	url = 'http://www.arrl.org/fcc/search'
	form = { 'data[Search][terms]' : 'Li Li' }
	data = urllib.urlencode(form)
	res = urllib2.urlopen(url, data).read()
	return res

def parse_fccapplication(lines):
	#                                                                            callsign
	#                                                                            name
	#                                                                            frn
	#                                                                            purpose
	#                                                                            service
	#                                            number                          date                     status
	ms = re.findall('title="Application Details">\s*(\d+)\s*</a>.*?</td>(?:.*?<td.*?</td>){6}.*?<td.*?>\s*(\w+)\s*.*?</td>.*?</tr>', lines, re.DOTALL)
	for m in ms:
		application = m[0]
		status = m[1]
		print 'Found %s %s' % (application, status)
		if is_in_pool(application, status):
			continue
		else:
			send_email('FCC application: %s %s' % (application, status))
			return True
	return False

def parse_fcclicense(lines):
	#                                                                name
	#                                                                frn
	#                                         number                 service                  status
	ms = re.findall('title="View Licensee">(\w+)</a>.*?</td>(?:.*?<td.*?</td>){3}.*?<td.*?>\s*(\w+)\s*.*?</td>.*?</tr>', lines, re.DOTALL)
	for m in ms:
		callsign = m[0]
		status = m[1]
		print 'Found %s %s' % (callsign, status)
		if is_in_pool(callsign, status):
			continue
		else:
			send_email('FCC license: %s %s' % (callsign, status))
			return True
	return False

def parse_arrl(lines):
	callsign = None
	for line in lines.splitlines():
		line.strip()
		m = re.match('.*Li, Li, (\w+).*', line)
		if m:
			callsign = m.group(1)
		m = re.match('.*FRN: (\d+).*', line)
		if m:
			frn = m.group(1)
			if frn == '0123456789' and callsign:
				print 'Found %s' % callsign
				if is_in_pool(callsign):
					callsign = None
					continue
				else:
					send_email('ARRL callsign: %s' % callsign)
					return True
			else:
				callsign = None
				continue
	return False

def send_email(msg):
	print "Sending email..."
	to_address ='"Li Li"<eggonlea@gmail.com>'
	body = msg
	subject="Callsign!"
	from_address='"Myself"<aawlbt@gmail.com>'
	smtp_server = 'smtp.gmail.com'
	smtp_port= 587
	smtp_user="aawlbt@gmail.com"
	smtp_password="xxx"

	#---------compose-------
	msg = text(body)
	msg['Subject'] = subject
	msg['From'] = from_address
	msg['To'] = to_address

	#---------send-------
	server = smtplib.SMTP(smtp_server, smtp_port)
	server.ehlo()
	server.starttls()
	server.login(smtp_user, smtp_password)
	server.sendmail(from_address, to_address, msg.as_string())
	server.quit()
	print "Done"
 
if __name__ == '__main__':
	cont = True
	while cont:
		print
		print '========================'
		print time.asctime()
		print '========================'

		try:
			print
			res = search_fccapplication()
			if parse_fccapplication(res) == True:
				cont = False
		except:
			print 'Error checking FCC application'

		try:
			print
			res = search_fcclicense()
			if parse_fcclicense(res) == True:
				cont = False
		except:
			print 'Error checking FCC license'

		try:
			print
			res = search_arrl()
			if parse_arrl(res) == True:
				cont = False
		except:
			print 'Error checking ARRL callsign'

		if cont:
			print
			print 'Sleeping...'
			time.sleep(1800)

	print 'Exit'
