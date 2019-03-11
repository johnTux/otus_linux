#!/usr/bin/env bash

cp /vagrant/time.conf /etc/security
cp /vagrant/sshd /etc/pam.d

groupadd admin
useradd user1
echo 123456789 | passwd user1 --stdin
usermod -a -G admin user1

useradd user2
echo 123456789 | passwd user2 --stdin

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
