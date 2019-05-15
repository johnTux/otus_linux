# Домашнее задание №20 "VPN"

## Описание

1. Между двумя виртуалками поднять vpn в режимах:

- tun
- tap

Прочуствовать разницу.

2. Поднять RAS, на базе OpenVPN, с клиентскими сертификатами. Подключиться с локальной машины на виртуалку.

### 1. Между двумя виртуалками поднять vpn в режимах tun, tap

Для запуска стенда, необходимо выполнить ```vagrant up``` из директории **[v1](https://github.com/johnTux/otus_linux/tree/master/task-20/v1)**.

В результате поднимутся четыре виртуалки **serverTap**, **clientTap**, **serverTun**, **clientTun**, а также пакет **iperf** для тестирования скорости передачи данных.

В итоге скорость передачи в режиме **tun** немного выше.

<details>
<summary><code>Режим tun</code></summary>

```
[vagrant@serverTun ~]$ iperf -s -i 5 &
[1] 6011
[vagrant@serverTun ~]$ ------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.9.0.1 port 5001 connected with 10.9.0.2 port 53816
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 5.0 sec   160 MBytes   269 Mbits/sec
[  4]  5.0-10.0 sec   174 MBytes   292 Mbits/sec
[  4] 10.0-15.0 sec   168 MBytes   282 Mbits/sec
[  4] 15.0-20.0 sec   167 MBytes   281 Mbits/sec
[  4] 20.0-25.0 sec   168 MBytes   282 Mbits/sec
[  4] 25.0-30.0 sec   174 MBytes   291 Mbits/sec
[  4]  0.0-30.0 sec  1012 MBytes   283 Mbits/sec

[vagrant@clientTun ~]$ iperf -c 10.9.0.1 -t 30 -i 5
------------------------------------------------------------
Client connecting to 10.9.0.1, TCP port 5001
TCP window size: 81.0 KByte (default)
------------------------------------------------------------
[  3] local 10.9.0.2 port 53816 connected with 10.9.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 5.0 sec   161 MBytes   270 Mbits/sec
[  3]  5.0-10.0 sec   174 MBytes   292 Mbits/sec
[  3] 10.0-15.0 sec   168 MBytes   283 Mbits/sec
[  3] 15.0-20.0 sec   167 MBytes   280 Mbits/sec
[  3] 20.0-25.0 sec   168 MBytes   282 Mbits/sec
[  3] 25.0-30.0 sec   173 MBytes   291 Mbits/sec
[  3]  0.0-30.0 sec  1012 MBytes   283 Mbits/sec
```

</details>

<details>
<summary><code>Режим tap</code></summary>

```
[vagrant@serverTap ~]$ iperf -s -i 5 &
[2] 5580
[1]   Done                    iperf -s
[vagrant@serverTap ~]$ ------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.8.0.1 port 5001 connected with 10.8.0.2 port 55996
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 5.0 sec   160 MBytes   268 Mbits/sec
[  4]  5.0-10.0 sec   165 MBytes   277 Mbits/sec
[  4] 10.0-15.0 sec   168 MBytes   282 Mbits/sec
[  4] 15.0-20.0 sec   166 MBytes   279 Mbits/sec
[  4] 20.0-25.0 sec   165 MBytes   277 Mbits/sec
[  4] 25.0-30.0 sec   166 MBytes   278 Mbits/sec
[  4]  0.0-30.0 sec   991 MBytes   277 Mbits/sec

[vagrant@clientTap ~]$ iperf -c 10.8.0.1 -t 30 -i 5
------------------------------------------------------------
Client connecting to 10.8.0.1, TCP port 5001
TCP window size: 81.0 KByte (default)
------------------------------------------------------------
[  3] local 10.8.0.2 port 55996 connected with 10.8.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 5.0 sec   160 MBytes   268 Mbits/sec
[  3]  5.0-10.0 sec   166 MBytes   278 Mbits/sec
[  3] 10.0-15.0 sec   168 MBytes   282 Mbits/sec
[  3] 15.0-20.0 sec   166 MBytes   278 Mbits/sec
[  3] 20.0-25.0 sec   166 MBytes   278 Mbits/sec
[  3] 25.0-30.0 sec   166 MBytes   278 Mbits/sec
[  3]  0.0-30.0 sec   991 MBytes   277 Mbits/sec
```

</details>

### 2. Поднять RAS, на базе OpenVPN, с клиентскими сертификатами. Подключиться с локальной машины на виртуалку

Для запуска стенда, необходимо выполнить ```vagrant up``` из директории **[v2](https://github.com/johnTux/otus_linux/tree/master/task-20/v2)**.

В результате поднимутся две виртуалки **server** и **client** с возможностью прохождения трафика в обе стороны, по адресам сети 10.0.1.0/24, назначенным данным машинам.

Необходимые сертификаты были сгенерированы посредством скриптов в папке **[scripts](https://github.com/johnTux/otus_linux/tree/master/task-20/v2/scripts)**.