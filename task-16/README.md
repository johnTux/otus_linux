# Домашнее задание №16 "Разворачиваем сетевую лабораторию"

## Теоретическая часть

- Найти свободные подсети.
- Посчитать сколько узлов в каждой подсети, включая свободные.
- Указать broadcast адрес для каждой подсети.
- Проверить нет ли ошибок при разбиении.


### Сеть central:

- 192.168.0.0/28 - **directors**

14 - number of hosts

192.168.0.15 - boadcast address

- 192.168.0.16/28 - **free subnet**

14 - number of hosts

- 192.168.0.32/28 - **office hardware**

14 - number of hosts

192.168.0.47 - boadcast address

- 192.168.0.48/28 - **free subnet**

14 - number of hosts

- 192.168.0.64/26 - **wifi**

62 - number of hosts

192.168.0.127 - boadcast address

- 192.168.0.128/25 - **free subnet**

126 - number of hosts


### Сеть office1:

- 192.168.2.0/26 - **dev**

62 - number of hosts

192.168.2.63 - boadcast address

- 192.168.2.64/26 - **test servers**

62 - number of hosts

192.168.2.127 - boadcast address

- 192.168.2.128/26 - **managers**

62 - number of hosts

192.168.2.191 - boadcast address

- 192.168.2.192/26 - **office hardware**

62 - number of hosts

192.168.2.255 - boadcast address


### Сеть office2:

- 192.168.1.0/25 - **dev**

126 - number of hosts

192.168.1.127 - boadcast address

- 192.168.1.128/26 - **test servers**

62 - number of hosts

192.168.1.191 - boadcast address

- 192.168.1.192/26 - **office hardware**

62 - number of hosts

192.168.1.255 - boadcast address

Ошибок при разбиении на подсети нет.