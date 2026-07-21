#!/bin/bash

read -p "Are you sure? Press 'y' to reboot!" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo rebooting...
	/sbin/reboot
fi
