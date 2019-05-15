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

В результате на виртуалке будет установлен **openvpn server** с необходимыми сертификатами и конфигом **server.conf**.

Ниже описан процесс получения данных сертификатов - создание инфраструктуры открытых ключей (PKI).

Создаем инфраструктуру публичных ключей PKI:

```
# wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz

# tar -xzvf EasyRSA-unix-v3.0.6.tgz && mv EasyRSA-v3.0.6 ca && cd ca

# ./easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /root/ca/EasyRSA-v3.0.6/pki
```

Далее создаем удостоверяющий центр для OpenVPN:

```
# ./easyrsa build-ca nopass

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
...................................................................................................................................................+++
...................................................................................................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:server

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/root/ca/EasyRSA-v3.0.6/pki/ca.crt
```

Для удостоверяющего центра созданы ключ и сертификат:

```
# ls -la pki/private/
total 4
drwx------. 2 root root   20 May 11 21:04 .
drwx------. 8 root root  199 May 11 21:04 ..
-rw-------. 1 root root 1679 May 11 21:04 ca.key

# ls -la pki/ca.crt
-rw-------. 1 root root 1151 May 11 21:04 pki/ca.crt
```

Теперь можно создавать и подписывать сертификаты. Для облегчения работы можно подправить файл параметров easy-rsa для того, чтобы меньше вводить информации. Для этого копируем файл vars.example в файл vars:

```
# cp vars.example vars
```

Расскомментируем и правим в vars строчки:

```
set_var EASYRSA_REQ_COUNTRY     "RU"
set_var EASYRSA_REQ_PROVINCE    "SPb"
set_var EASYRSA_REQ_CITY        "SPb"
set_var EASYRSA_REQ_ORG         "OTUS"
set_var EASYRSA_REQ_EMAIL       "me@example.net"
set_var EASYRSA_REQ_OU          "Linux"
```

Создаем ключ и запрос на сертификат сервера:

```
# ./easyrsa gen-req server nopass

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
....................+++
........+++
writing new private key to '/root/ca/EasyRSA-v3.0.6/pki/private/server.key.YekVoYKzEY'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:

Keypair and certificate request completed. Your files are:
req: /root/ca/EasyRSA-v3.0.6/pki/reqs/server.req
key: /root/ca/EasyRSA-v3.0.6/pki/private/server.key
```

Создаем и подписываем сертификат сервера:

```
# ./easyrsa sign-req server server

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 1080 days:

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /root/ca/EasyRSA-v3.0.6/pki/safessl-easyrsa.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Apr 25 18:40:10 2022 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /root/ca/EasyRSA-v3.0.6/pki/issued/server.crt
```

Создаем ключ Диффи-Хелмана:

```
# ./easyrsa gen-dh

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
...............................................................+...............................+......................................................................................................................................................................................................+......................................................................................................................+...................................+..........................+.....................................................................................................................................++*++*

DH parameters of size 2048 created at /root/ca/EasyRSA-v3.0.6/pki/dh.pem
```

Для создания статического ключа HMAC, выполним:

```
# openvpn --genkey --secret ta.key
```

Все необходимые ключи и сертификаты для сервера созданы:

- ca.crt - cертификат удостоверяющего центра;
- server.crt - cертификат сервера OpenVPN;
- server.key - приватный ключ сервера OpenVPN;
- dh.pem - ключ Диффи-Хелмана для обеспечения защиты трафика от расшифровки;
- ta.key - ключ HMAC для дополнительной защиты от DoS-атак и флуда.

Далее создаем ключ и запрос сертификата для клиента:

```
# ./easyrsa gen-req client nopass

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
.........................................+++
............................................+++
writing new private key to '/root/ca/EasyRSA-v3.0.6/pki/private/client.key.yORLKYE3dr'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [client]:

Keypair and certificate request completed. Your files are:
req: /root/ca/EasyRSA-v3.0.6/pki/reqs/client.req
key: /root/ca/EasyRSA-v3.0.6/pki/private/client.key
```

Создаем и подписываем сертификат клиента:

```
# ./easyrsa sign-req client client

Note: using Easy-RSA configuration from: ./vars

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 1080 days:

subject=
    commonName                = client


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /root/ca/EasyRSA-v3.0.6/pki/safessl-easyrsa.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client'
Certificate is to be certified until Apr 25 18:45:49 2022 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /root/ca/EasyRSA-v3.0.6/pki/issued/client.crt
```