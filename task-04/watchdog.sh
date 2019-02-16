#!/usr/bin/env bash

SERVICE=crond.service
PIDFILE=/var/run/crond.pid

if [ -f $PIDFILE ]; then
echo 'Service "'$SERVICE'" is running';
else
echo
echo 'Service "'$SERVICE'" is not running!';
echo
echo 'Start service "'$SERVICE'"? Write "yes" or "no"!';
read Keypress
case $Keypress in
   yes)
      /usr/bin/systemctl start $SERVICE
      echo
      echo 'Service "'$SERVICE'" is up!'
      ;;
   no)
      echo
      echo 'Service "'$SERVICE'" is down!'
      ;;
esac
fi