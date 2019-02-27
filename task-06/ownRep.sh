#!/usr/bin/env bash

setenforce 0

yum install net-tools yum-utils createrepo mailcap system-logos apr apr-util -y
mkdir -p /usr/share/repository

cp files/httpd-2.4.6-88.el7.x86_64.rpm /usr/share/repository && \
cp files/httpd-tools-2.4.6-88.el7.x86_64.rpm /usr/share/repository

createrepo /usr/share/repository
cp files/otus.repo /etc/yum.repos.d

yum --disablerepo=* --enablerepo=otus_local install httpd.x86_64 -y

systemctl enable httpd.service
systemctl start httpd.service