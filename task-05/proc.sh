#!/usr/bin/env bash

PID=`ls /proc/ | egrep "^[0-9]" | sort -n`
STATUS=/proc/$PID
echo
awk 'BEGIN {print "PID     STAT     COMMAND\n-----------------------------------"}'

for proc in $PID
do
if [ -f "/proc/$proc/status" ]; then
STAT=`cat /proc/$proc/status | grep 'State:' | awk '{print $2}'`
COMMAND=`cat /proc/"$proc"/cmdline`
echo -n -e $proc '\t' $STAT '\t' $COMMAND
echo
fi
done