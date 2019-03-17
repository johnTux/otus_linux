# Вопросы

Чтобы не прописывать пути до приватных ключей, для подключения по ssh к машинам, решил включить авторизацию по паролям.

Часть **Vagrantfile**:

```
 box.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      systemctl restart sshd
    SHELL
```

Инвентори файл **hosts**:

```
[server]
ipaserver   ansible_host=192.168.10.10   ansible_port=22   ansible_user=vagrant   ansible_ssh_pass=vagrant

[client]
ipaclient   ansible_host=192.168.10.11   ansible_port=22   ansible_user=vagrant   ansible_ssh_pass=vagrant
```

Запускаю плейбук **ipaserver.yml**. Последняя таска **TASK [server : Setup freeipa server]** завершается с ошибкой - лог прикрепил в личном кабинете, т.к. в гите он неполный.