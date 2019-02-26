# Домашнее задание №6 "Управление пакетами. Дистрибьюция софта"

## 1. Свой RPM

Установка пакетов:

* ```# yum install net-tools redhat-lsb-core rpmdevtools rpm-build createrepo yum-utils gcc gcc-c++ -y```

Для примера возьмем пакет ```httpd```.

Загрузка исходников пакета ```httpd``` и его установка:

* ```# yumdownloader --source httpd.x86_64```
* ```# rpm -ivh httpd-2.4.6-88.el7.centos.src.rpm```

Установка зависимостей, чтобы в процессе сборки не было ошибок:

* ```# yum-builddep rpmbuild/SPECS/httpd.spec```

Правка конфига для запуска сервиса, после его установки, на порту 9090:

* ```# nano rpmbuild/SOURCES/httpd.conf```

Listen 9090

Сборка RPM-пакета и установка сервиса ```httpd```:

* ```# rpmbuild -bb rpmbuild/SPECS/httpd.spec```

* ```# cd rpmbuild/RPMS/x86_64```

* ```# yum localinstall httpd-tools-2.4.6-88.el7.x86_64.rpm -y```

* ```# yum localinstall httpd-2.4.6-88.el7.x86_64.rpm -y```

* ```# systemctl start httpd.service```

\# systemctl status httpd.service

```
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2019-02-26 11:58:32 UTC; 33min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 4012 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─4012 /usr/sbin/httpd -DFOREGROUND
           ├─4013 /usr/sbin/httpd -DFOREGROUND
           ├─4014 /usr/sbin/httpd -DFOREGROUND
           ├─4015 /usr/sbin/httpd -DFOREGROUND
           ├─4016 /usr/sbin/httpd -DFOREGROUND
           └─4017 /usr/sbin/httpd -DFOREGROUND

Feb 26 11:58:32 otuslinux systemd[1]: Starting The Apache HTTP Server...
Feb 26 11:58:32 otuslinux httpd[4012]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 12... message
Feb 26 11:58:32 otuslinux systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

\# netstat -lntp

```
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd           
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      3204/sshd           
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      3399/master         
tcp6       0      0 :::111                  :::*                    LISTEN      1/systemd           
tcp6       0      0 :::22                   :::*                    LISTEN      3204/sshd           
tcp6       0      0 ::1:25                  :::*                    LISTEN      3399/master         
tcp6       0      0 :::9090                 :::*                    LISTEN      4012/httpd
```

## 2. Свой репозиторий, с размещением в нем созданного RPM-пакета

Создание директории для репозитория:

* ```# mkdir -p /usr/share/repository```

Копирование необходимых пакетов:

* ```# cp rpmbuild/RPMS/x86_64/httpd-2.4.6-88.el7.x86_64.rpm /usr/share/repository```

* ```# cp rpmbuild/RPMS/x86_64/httpd-tools-2.4.6-88.el7.x86_64.rpm /usr/share/repository```

Инициализируем репозиторий:

* ```# createrepo /usr/share/repository```

Добавим репозиторий в ```/etc/yum.repos.d```:

* ``` # nano /etc/yum.repos.d/otus.repo```

```
[otus_local]
name=Otus_Linux
baseurl=file:///usr/share/repository
enabled=0
gpgcheck=0
```

\# yum repolist disabled | grep otus_local

```otus_local                              Otus_Linux```

\# yum list | grep otus_local

```
httpd.x86_64                               2.4.6-88.el7                @otus_local
httpd-tools.x86_64                         2.4.6-88.el7                @otus_local
```

Устанока сервиса из локального репозитория:

* ```# yum --disablerepo=* --enablerepo=otus_local install httpd.x86_64```

```
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package httpd.x86_64 0:2.4.6-88.el7 will be installed
--> Processing Dependency: httpd-tools = 2.4.6-88.el7 for package: httpd-2.4.6-88.el7.x86_64
--> Running transaction check
---> Package httpd-tools.x86_64 0:2.4.6-88.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=================================================================================================================================================
 Package                            Arch                          Version                                Repository                         Size
=================================================================================================================================================
Installing:
 httpd                              x86_64                        2.4.6-88.el7                           otus_local                        2.7 M
Installing for dependencies:
 httpd-tools                        x86_64                        2.4.6-88.el7                           otus_local                         89 k

Transaction Summary
=================================================================================================================================================
Install  1 Package (+1 Dependent package)

Total download size: 2.8 M
Installed size: 9.5 M
Is this ok [y/d/N]: y
Downloading packages:
-------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                             74 MB/s | 2.8 MB  00:00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : httpd-tools-2.4.6-88.el7.x86_64                                                                                               1/2 
  Installing : httpd-2.4.6-88.el7.x86_64                                                                                                     2/2 
  Verifying  : httpd-2.4.6-88.el7.x86_64                                                                                                     1/2 
  Verifying  : httpd-tools-2.4.6-88.el7.x86_64                                                                                               2/2 

Installed:
  httpd.x86_64 0:2.4.6-88.el7                                                                                                                    

Dependency Installed:
  httpd-tools.x86_64 0:2.4.6-88.el7                                                                                                              

Complete!
```

\# systemctl start httpd.service

\# systemctl status httpd.service

```
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2019-02-26 12:57:24 UTC; 45s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 11952 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─11952 /usr/sbin/httpd -DFOREGROUND
           ├─11953 /usr/sbin/httpd -DFOREGROUND
           ├─11954 /usr/sbin/httpd -DFOREGROUND
           ├─11955 /usr/sbin/httpd -DFOREGROUND
           ├─11956 /usr/sbin/httpd -DFOREGROUND
           └─11957 /usr/sbin/httpd -DFOREGROUND

Feb 26 12:57:24 otuslinux systemd[1]: Starting The Apache HTTP Server...
Feb 26 12:57:24 otuslinux httpd[11952]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 1... message
Feb 26 12:57:24 otuslinux systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

\# netstat -lntp

```
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd           
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      3204/sshd           
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      3399/master         
tcp6       0      0 :::111                  :::*                    LISTEN      1/systemd           
tcp6       0      0 :::22                   :::*                    LISTEN      3204/sshd           
tcp6       0      0 ::1:25                  :::*                    LISTEN      3399/master         
tcp6       0      0 :::9090                 :::*                    LISTEN      11952/httpd
```