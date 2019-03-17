# Домашнее задание №11 "LDAP. Централизованная авторизация и аутентификация"

Запуск стенда:

- установка виртуальных машин:

```
vagrant up server
vagrant up client
```

- прописать в **hosts** - "ansible_ssh_private_key_file=" для сервера и клиента;

- запустить плейбук **ipaserver.yml**;

- после установки и настройки сервера выполнить **vagrant ssh server** и выдать билет kerberos:

```
kinit admin
```

- запустить плейбук **ipaclient.yml**
