# Домашнее задание №10 "Пользователи и группы. Авторизация и аутентификация"

## 1. Запретить всем пользователям, кроме группы admin логин в выходные и праздничные дни

## 2. Дать конкретному пользователю права рута

### Root права новому пользователю

Чтобы создать пользователя с абсолютно теми же правами, что и у пользователя root, необходимо назначить ему тот же ID пользователя, что у root (UID 0) и тот же ID группы (GID 0).

Для этого используется следующая команда:

```
# useradd -ou 0 -g 0 userRoot
# passwd userRoot
```

Проверим:

```
# id userRoot
uid=0(root) gid=0(root) groups=0(root)

# grep userRoot /etc/passwd
userRoot:x:0:0::/home/userRoot:/bin/bash
```

### Root права существующему пользователю

#### 1. Изменение UID и GID в /etc/passwd для пользователя userExist1

Проверим наличие обычного пользователя:

```
# grep userExist1 /etc/passwd
userExist1:x:1003:1003::/home/userExist1:/bin/bash
```

Отредактируем у данного пользователя UID и GID в файле /etc/passwd:

```
# nano /etc/passwd

# grep userExist1 /etc/passwd
userExist1:x:0:0::/home/userExist1:/bin/bash
```

#### 2. Добавление пользователя userExist2 в группу "wheel"

Проверим наличие обычного пользователя:

```
# grep userExist2 /etc/passwd
userExist2:x:1004:1004::/home/userExist2:/bin/bash
```

Добавим пользователя в группу "wheel"

```
# usermod -a -G wheel userExist2

# id userExist2
uid=1004(userExist2) gid=1004(userExist2) groups=1004(userExist2),10(wheel)
```

Далее отредактируем файл /etc/sudoers, посредством команды visudo (раскомментируем строку для группы "wheel"):

```
# visudo
## Allows people in group wheel to run all commands
%wheel  ALL=(ALL)       ALL
```

После этого у пользователя userExist2 есть возможность запуска всех команд через sudo.

#### 3. Добавление пользователя userExist3 в группу "root"

Данная возможность предоставляет не все привилегии пользователя root.

Проверим наличие обычного пользователя:

```
# grep userExist3 /etc/passwd
userExist3:x:1005:1005::/home/userExist3:/bin/bash
```

Добавим пользователя в группу "root"

```
# usermod -a -G root userExist3
```
Проверим:

```
# id userExist3
uid=1005(userExist3) gid=1005(userExist3) groups=1005(userExist3),0(root)
```

#### 4. Добавление разрешения "cap_sys_admin" пользователю userCap через возможности Linux

Проверим наличие обычного пользователя:

```
# grep userCap /etc/passwd
userCap:x:1002:1002::/home/userCap:/bin/bash
```

Проверим установленные пакеты, отвечающие за Linux capabilities:

```
# rpm -qa | grep libcap
libcap-ng-0.7.5-4.el7.x86_64
libcap-2.22-9.el7.x86_64
```

Добавим возможность и пользователя в файл /etc/security/capability.conf:

```
# cat /etc/security/capability.conf
cap_sys_admin   userCap
```

Затем добавим модуль pam_cap (модуль PAM для установки наследуемых возможностей) в службу /etc/pam.d/su.
Модуль pam_cap должен обязательно быть установлен до модуля pam_rootok, т.к. у пользователя userCap - UID отличный от нуля.

\# nano /etc/pam.d/su

```
#%PAM-1.0
auth            optional        pam_cap.so
auth            sufficient	pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
#auth           sufficient	pam_wheel.so trust use_uid
# Uncomment the following line to require a user to be in the "wheel" group.
#auth           required        pam_wheel.so use_uid
auth            substack        system-auth
auth            include         postlogin
account         sufficient	pam_succeed_if.so uid = 0 use_uid quiet
account         [success=1 default=ignore] \
                                pam_succeed_if.so user = vagrant use_uid quiet
account         required        pam_succeed_if.so user notin root:vagrant
account         include         system-auth
password        include         system-auth
session         include         system-auth
session         include         postlogin
session         optional        pam_xauth.so
```

Флаг optional имеет значение, т.к. применяемый с ним модуль единственный в данной службе (su).

Проверим возможности пользователя userCap:

```
# su - userCap
Last login: Sun Mar 10 12:08:03 UTC 2019 on pts/0
$ capsh --print
Current: = cap_sys_admin+i
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,35,36
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=1002(userCap)
gid=1002(userCap)
groups=1002(userCap)
```

```Current: = cap_sys_admin+i``` - ключевая строка, информирующая о Linux capabilities у данного пользователя.
