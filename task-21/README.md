# Домашнее задание №21 "Cтроим бонды и вланы"

## Описание

В Office1, в тестовой подсети, появляются сервера с доп. интерфесами и адресами в internal сети testLAN:

- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1
- testServer2- 10.10.10.1

1. Развести вланами:

- testClient1 <-> testServer1

- testClient2 <-> testServer2

2. Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд. Проверить работу c отключением интерфейсов.

Для запуска стенда, необходимо выполнить ```vagrant up```.

В результате будут подняты семь ВМ:

```
inetRouter
centralRouter
office1Router
testServer1
testClient1
testServer2
testClient2
```

Последние четыре ВМ будут разведены вланами.

**Проверка работы интерфеса bond.**

Определим активный интерфес в bond0 на inetRouter:

```
[vagrant@inetRouter ~]$ cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:93:3b:e4
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:b1:b4:92
Slave queue ID: 0
```

Выполним ping с centralRouter на inetRouter с последующим отключением активного интерфейса eth1:

```
[vagrant@inetRouter ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:27:81:a2 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    inet6 fe80::5054:ff:fe27:81a2/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP qlen 1000
    link/ether 08:00:27:93:3b:e4 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP qlen 1000
    link/ether 08:00:27:b1:b4:92 brd ff:ff:ff:ff:ff:ff
5: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 08:00:27:93:3b:e4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global bond0
    inet6 fe80::a00:27ff:fe93:3be4/64 scope link 
       valid_lft forever preferred_lft forever
```

```
[vagrant@centralRouter ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:75:dc:3d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 82013sec preferred_lft 82013sec
    inet6 fe80::5054:ff:fe75:dc3d/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:2c:19:cf brd ff:ff:ff:ff:ff:ff
    inet 192.168.254.1/30 brd 192.168.254.3 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe2c:19cf/64 scope link 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:0b:02:e9 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:e7:a1:46 brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:0b:02:e9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.2/30 brd 192.168.255.3 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe0b:2e9/64 scope link 
       valid_lft forever preferred_lft forever
```

```
[vagrant@centralRouter ~]$ ping 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
64 bytes from 192.168.255.1: icmp_seq=1 ttl=64 time=0.552 ms
64 bytes from 192.168.255.1: icmp_seq=2 ttl=64 time=0.641 ms
64 bytes from 192.168.255.1: icmp_seq=3 ttl=64 time=0.597 ms
64 bytes from 192.168.255.1: icmp_seq=4 ttl=64 time=0.593 ms
64 bytes from 192.168.255.1: icmp_seq=5 ttl=64 time=0.663 ms
64 bytes from 192.168.255.1: icmp_seq=6 ttl=64 time=0.362 ms
64 bytes from 192.168.255.1: icmp_seq=7 ttl=64 time=0.650 ms
64 bytes from 192.168.255.1: icmp_seq=8 ttl=64 time=0.226 ms
64 bytes from 192.168.255.1: icmp_seq=9 ttl=64 time=2.42 ms
64 bytes from 192.168.255.1: icmp_seq=10 ttl=64 time=0.603 ms
64 bytes from 192.168.255.1: icmp_seq=11 ttl=64 time=2.32 ms
64 bytes from 192.168.255.1: icmp_seq=12 ttl=64 time=0.644 ms
64 bytes from 192.168.255.1: icmp_seq=13 ttl=64 time=0.680 ms
64 bytes from 192.168.255.1: icmp_seq=14 ttl=64 time=0.647 ms
64 bytes from 192.168.255.1: icmp_seq=15 ttl=64 time=0.627 ms
64 bytes from 192.168.255.1: icmp_seq=16 ttl=64 time=0.625 ms
64 bytes from 192.168.255.1: icmp_seq=17 ttl=64 time=0.731 ms
64 bytes from 192.168.255.1: icmp_seq=18 ttl=64 time=0.673 ms
64 bytes from 192.168.255.1: icmp_seq=19 ttl=64 time=0.842 ms
64 bytes from 192.168.255.1: icmp_seq=20 ttl=64 time=0.676 ms
64 bytes from 192.168.255.1: icmp_seq=21 ttl=64 time=0.640 ms
64 bytes from 192.168.255.1: icmp_seq=22 ttl=64 time=0.656 ms
64 bytes from 192.168.255.1: icmp_seq=23 ttl=64 time=0.662 ms
64 bytes from 192.168.255.1: icmp_seq=24 ttl=64 time=0.731 ms
64 bytes from 192.168.255.1: icmp_seq=25 ttl=64 time=0.684 ms
64 bytes from 192.168.255.1: icmp_seq=26 ttl=64 time=0.595 ms
64 bytes from 192.168.255.1: icmp_seq=27 ttl=64 time=0.877 ms
64 bytes from 192.168.255.1: icmp_seq=28 ttl=64 time=0.666 ms
64 bytes from 192.168.255.1: icmp_seq=29 ttl=64 time=0.696 ms
64 bytes from 192.168.255.1: icmp_seq=30 ttl=64 time=0.248 ms
64 bytes from 192.168.255.1: icmp_seq=31 ttl=64 time=0.645 ms
^C
--- 192.168.255.1 ping statistics ---
31 packets transmitted, 31 received, 0% packet loss, time 30038ms
rtt min/avg/max/mdev = 0.226/0.738/2.429/0.450 ms
```

После отключения интерфейса eth1 на inetRouter произошла небольшая задержка (переключение интерфейса), как видно из рисунка выше, т.е. активным интерфейсом стал eth2:

```
[root@inetRouter vagrant]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:b1:b4:92
Slave queue ID: 0
```