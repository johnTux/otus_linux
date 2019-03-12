# Домашнее задание №8 "Инициализация системы. Systemd и SysV"

## 1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

Cоздаём файл с конфигурацией для сервиса в директории **/etc/sysconfig** - из неё сервис будет брать необходимые переменные.

```
# cat /etc/sysconfig/task08
WORD="ALERT"
LOG=/var/log/watchlog.log
```

Затем создаем **/var/log/watchlog.log** и пишем туда любые строки, плюс ключевое слово "ALERT":

```
# cp /var/log/messages /var/log/watchlog.log
# cat /var/log/watchlog.log
Mar 11 22:55:11 localhost systemd: Started Session 3 of user vagrant.
Mar 11 22:55:11 localhost systemd-logind: New session 3 of user vagrant.
Mar 11 22:55:11 localhost systemd: Starting Session 3 of user vagrant.
Mar 11 22:55:11 localhost systemd-logind: Removed session 3.
Mar 11 22:55:11 localhost systemd-logind: Removed session 2.
Mar 11 22:55:11 localhost systemd: Removed slice User Slice of vagrant.
Mar 11 22:55:11 localhost systemd: Stopping User Slice of vagrant.
Mar 11 23:00:42 localhost systemd: Created slice User Slice of vagrant.
Mar 11 23:00:42 localhost systemd: Starting User Slice of vagrant.
Mar 11 23:00:42 localhost systemd: Started Session 4 of user vagrant.
Mar 11 23:00:42 localhost systemd-logind: New session 4 of user vagrant.
Mar 11 23:00:42 localhost systemd: Starting Session 4 of user vagrant.
Mar 11 23:00:55 localhost yum[2925]: Installed: nano-2.3.1-10.el7.x86_64
Mar 11 23:01:01 localhost systemd: Created slice User Slice of root.
Mar 11 23:01:01 localhost systemd: Starting User Slice of root.
Mar 11 23:01:01 localhost systemd: Started Session 5 of user root.
Mar 11 23:01:01 localhost systemd: Starting Session 5 of user root.
Mar 11 ALERT
```

Создадим скрипт и сделаем его исполняемым:

```
# cat /opt/task08.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if [ "grep $WORD $LOG &> /dev/null" ]; then 

  logger "$DATE: Watchdog found WORD!"
else
  exit 0
fi

# chmod +x /opt/task08.sh
```

Команда **logger** отправляет лог в системный журнал.

Создадим юнит для сервиса:

```
# cat /etc/systemd/system/task08.service
[Unit]
Description=My watchdog service

[Service]
Type=simple
EnvironmentFile=/etc/sysconfig/task08
ExecStart=/opt/task08.sh $WORD $LOG
```

Создадим юнит для таймера:

```
# cat /etc/systemd/system/task08.timer
[Unit]
Description=Run watchdog script every 30 second

[Timer]
OnUnitActiveSec=30s
AccuracySec=1us
Unit=task08.service
Persistent=true

[Install]
WantedBy=timers.target
```

Перезапустим **systemd**:

```
# systemctl daemon-reload
```

Установим и запустим таймер для сервиса:

```
# systemctl enable task08.timer
# systemctl start task08.timer
```

Убедимся, что таймер работает:

```
# systemctl status task08.timer
● task08.timer - Run watchdog script every 30 second
   Loaded: loaded (/etc/systemd/system/task08.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Tue 2019-03-12 01:35:57 UTC; 4s ago

Mar 12 01:35:57 localhost.localdomain systemd[1]: Started Run watchdog script every 30 second.
Mar 12 01:35:57 localhost.localdomain systemd[1]: Starting Run watchdog script every 30 second.
```

и

```
# systemctl list-timers --all
NEXT                         LEFT     LAST                         PASSED       UNIT                         ACTIVATES
Tue 2019-03-12 01:37:27 UTC  22s left Tue 2019-03-12 01:36:57 UTC  7s ago       task08.timer                 task08.service
Tue 2019-03-12 23:09:47 UTC  21h left Mon 2019-03-11 23:09:47 UTC  2h 27min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
n/a                          n/a      n/a                          n/a          systemd-readahead-done.timer systemd-readahead-done.service

3 timers listed.
```

Проверить работу таймера можно следующей командой:

```
# tail -f /var/log/messages
Mar 12 01:35:57 localhost systemd: Started Run watchdog script every 30 second.
Mar 12 01:35:57 localhost systemd: Starting Run watchdog script every 30 second.
Mar 12 01:35:57 localhost systemd: Started My watchdog service.
Mar 12 01:35:57 localhost systemd: Starting My watchdog service...
Mar 12 01:35:57 localhost root: Tue Mar 12 01:35:57 UTC 2019: Watchdog found WORD!
Mar 12 01:36:27 localhost systemd: Started My watchdog service.
Mar 12 01:36:27 localhost systemd: Starting My watchdog service...
Mar 12 01:36:27 localhost root: Tue Mar 12 01:36:27 UTC 2019: Watchdog found WORD!
Mar 12 01:36:57 localhost systemd: Started My watchdog service.
Mar 12 01:36:57 localhost systemd: Starting My watchdog service...
Mar 12 01:36:57 localhost root: Tue Mar 12 01:36:57 UTC 2019: Watchdog found WORD!
Mar 12 01:37:27 localhost systemd: Started My watchdog service.
Mar 12 01:37:27 localhost systemd: Starting My watchdog service...
Mar 12 01:37:27 localhost root: Tue Mar 12 01:37:27 UTC 2019: Watchdog found WORD!
Mar 12 01:37:57 localhost systemd: Started My watchdog service.
Mar 12 01:37:57 localhost systemd: Starting My watchdog service...
Mar 12 01:37:57 localhost root: Tue Mar 12 01:37:57 UTC 2019: Watchdog found WORD!
Mar 12 01:38:27 localhost systemd: Started My watchdog service.
Mar 12 01:38:27 localhost systemd: Starting My watchdog service...
Mar 12 01:38:27 localhost root: Tue Mar 12 01:38:27 UTC 2019: Watchdog found WORD!
Mar 12 01:38:57 localhost systemd: Started My watchdog service.
Mar 12 01:38:57 localhost systemd: Starting My watchdog service...
Mar 12 01:38:57 localhost root: Tue Mar 12 01:38:57 UTC 2019: Watchdog found WORD!
Mar 12 01:39:27 localhost systemd: Started My watchdog service.
Mar 12 01:39:27 localhost systemd: Starting My watchdog service...
Mar 12 01:39:27 localhost root: Tue Mar 12 01:39:27 UTC 2019: Watchdog found WORD!
```

## 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться

Устанавливаем spawn-fcgi и необходимые для него пакеты:

```# yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y```

/etc/rc.d/init.d/spawn-fcg - init-скрипт, который необходимо переписать.

Раскомментируем строки в ```/etc/sysconfig/spawn-fcgi``` и подправим параметр ```OPTIONS```:

\# nano /etc/sysconfig/spawn-fcgi

```
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
#OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
```

Юнит файл ```spawn-fcgi.service```:

\# nano /etc/systemd/system/spawn-fcgi.service

```
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
```

\# systemctl start spawn-fcgi.service

\# systemctl status spawn-fcgi.service

```
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2019-03-03 11:52:19 UTC; 35s ago
 Main PID: 1661 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─1661 /usr/bin/php-cgi
           ├─1662 /usr/bin/php-cgi
           ├─1663 /usr/bin/php-cgi
           ├─1664 /usr/bin/php-cgi
           ├─1665 /usr/bin/php-cgi
           ├─1666 /usr/bin/php-cgi
           ├─1667 /usr/bin/php-cgi
           ├─1668 /usr/bin/php-cgi
           ├─1669 /usr/bin/php-cgi
           ├─1670 /usr/bin/php-cgi
           ├─1671 /usr/bin/php-cgi
           ├─1672 /usr/bin/php-cgi
           ├─1673 /usr/bin/php-cgi
           ├─1674 /usr/bin/php-cgi
           ├─1675 /usr/bin/php-cgi
           ├─1676 /usr/bin/php-cgi
           ├─1677 /usr/bin/php-cgi
           ├─1678 /usr/bin/php-cgi
           ├─1679 /usr/bin/php-cgi
           ├─1680 /usr/bin/php-cgi
           ├─1681 /usr/bin/php-cgi
           ├─1682 /usr/bin/php-cgi
           ├─1683 /usr/bin/php-cgi
           ├─1684 /usr/bin/php-cgi
           ├─1685 /usr/bin/php-cgi
           ├─1686 /usr/bin/php-cgi
           ├─1687 /usr/bin/php-cgi
           ├─1688 /usr/bin/php-cgi
           ├─1689 /usr/bin/php-cgi
           ├─1690 /usr/bin/php-cgi
           ├─1691 /usr/bin/php-cgi
           ├─1692 /usr/bin/php-cgi
           └─1693 /usr/bin/php-cgi

Mar 03 11:52:19 lvm systemd[1]: Started Spawn-fcgi startup service by Otus.
Mar 03 11:52:19 lvm systemd[1]: Starting Spawn-fcgi startup service by Otus...
```

## 2. Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами

Для запуска нескольких экземпляров сервиса, будем использовать шаблон unit-файла httpd:

```# cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service```

Редактируем unit-файл:

\# nano /usr/lib/systemd/system/httpd@.service

```
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
# We want systemd to give httpd some time to finish gracefully, but still want
# it to kill httpd after TimeoutStopSec if something went wrong during the
# graceful stop. Normally, Systemd sends SIGTERM signal right after the
# ExecStop, which would kill httpd. We are sending useless SIGCONT here to give
# httpd time to finish.
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

В unit-файле ```httpd@.service``` задается опция ```%I```, для запуска веб-сервера с необходимым конфигурационным файлом.

Создадим файлы, указывающие веб-серверу, с каким конфигом запускаться:

\# nano /etc/sysconfig/httpd-first

```OPTIONS=-f conf/first.conf```

\# nano /etc/sysconfig/httpd-second

```OPTIONS=-f conf/second.conf```

Для удачного запуска, в конфигурационных файлах, должны быть указаны уникальные для каждого экземпляра опции ```PidFile``` и ```Listen```.

Сами конфигурационные файлы:

\# nano /etc/httpd/conf/first.conf

```
PidFile /var/run/httpd-first.pid
Listen 8080
```

\# nano /etc/httpd/conf/second.conf

```
PidFile /var/run/httpd-second.pid
Listen 9090
```

Временно отключим SELinux:

```# setenforce 0```

или

```# setenforce Permissive```

Запускаем несколько инстансов веб-сервера:

```
# systemctl start httpd

# systemctl start httpd@first

# systemctl start httpd@second
```

Проверяем запущенные процессы ```httpd```:

\# ss -tnulp | grep httpd

```
tcp    LISTEN     0      128      :::9090                 :::*                   users:(("httpd",pid=1973,fd=4),("httpd",pid=1972,fd=4),("httpd",pid=1971,fd=4),("httpd",pid=1970,fd=4),("httpd",pid=1969,fd=4),("httpd",pid=1968,fd=4),("httpd",pid=1967,fd=4))
tcp    LISTEN     0      128      :::8080                 :::*                   users:(("httpd",pid=1960,fd=4),("httpd",pid=1959,fd=4),("httpd",pid=1958,fd=4),("httpd",pid=1957,fd=4),("httpd",pid=1956,fd=4),("httpd",pid=1955,fd=4),("httpd",pid=1954,fd=4))
tcp    LISTEN     0      128      :::80                   :::*                   users:(("httpd",pid=1947,fd=4),("httpd",pid=1946,fd=4),("httpd",pid=1945,fd=4),("httpd",pid=1944,fd=4),("httpd",pid=1943,fd=4),("httpd",pid=1942,fd=4),("httpd",pid=1941,fd=4))
```

\# systemctl status httpd

```
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2019-03-03 12:19:33 UTC; 4min 21s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 1941 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─1941 /usr/sbin/httpd -DFOREGROUND
           ├─1942 /usr/sbin/httpd -DFOREGROUND
           ├─1943 /usr/sbin/httpd -DFOREGROUND
           ├─1944 /usr/sbin/httpd -DFOREGROUND
           ├─1945 /usr/sbin/httpd -DFOREGROUND
           ├─1946 /usr/sbin/httpd -DFOREGROUND
           └─1947 /usr/sbin/httpd -DFOREGROUND

Mar 03 12:19:33 lvm systemd[1]: Starting The Apache HTTP Server...
Mar 03 12:19:33 lvm httpd[1941]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
Mar 03 12:19:33 lvm systemd[1]: Started The Apache HTTP Server.
```

\# systemctl status httpd@first

```
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2019-03-03 12:19:40 UTC; 5min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 1954 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─1954 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1955 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1956 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1957 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1958 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1959 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─1960 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Mar 03 12:19:40 lvm systemd[1]: Starting The Apache HTTP Server...
Mar 03 12:19:40 lvm httpd[1954]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
Mar 03 12:19:40 lvm systemd[1]: Started The Apache HTTP Server.
```

\# systemctl status httpd@second

```
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2019-03-03 12:19:43 UTC; 8min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 1967 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─1967 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1968 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1969 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1970 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1971 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1972 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─1973 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Mar 03 12:19:43 lvm systemd[1]: Starting The Apache HTTP Server...
Mar 03 12:19:43 lvm httpd[1967]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
Mar 03 12:19:43 lvm systemd[1]: Started The Apache HTTP Server.
```