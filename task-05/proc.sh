#!/usr/bin/env bash

PROC=/proc

ls -a $PROC | grep -o '[0-9]*' | sort -n

#!/bin/bash

#PID=$PID
#STAT=$STAT
#COMMAND=$COMMAND
#pidDir="/proc/pidDir"
#awk 'BEGIN {print " PID STAT COMMAND\n-----------------------------------"}'
#cat /proc/1131/status | awk '$1 == "Pid:" {print " " $2}' > ps
#echo PID STAT COMMAND > ps
#cat ps

for proc in `ls /proc/ | egrep "^[0-9]" | sort -n`
do
if [ -d "/proc/$proc" ]; then
cd /proc/$proc
cat /proc/$proc/status | awk '$1 == "Pid:" {print " " $2}' > ps
continue
fi
#echo $proc
done