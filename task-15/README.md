# Домашнее задание №15 "Docker"

## Описание

#### Создание своего образа nginx на базе дистрибутива alpine linux

* [Dockerfile](https://github.com/johnTux/otus_linux/blob/master/task-15/Dockerfile) - файл для создания своего образа.

* [default.conf](https://github.com/johnTux/otus_linux/blob/master/task-15/default.conf) - конфиг nginx по умолчанию.

* [index.html](https://github.com/johnTux/otus_linux/blob/master/task-15/index.html) - html-страница.

Созданим образ из вышеприведенных файлов:

```
$ docker build -t johntux/task-15 .
```
Запустим контейнер из образа:

```
$ docker run -d --name task-15 johntux/task-15
```

Определим ip-адрес запущенного контейнера:

```
$ docker inspect task-15 | grep IPA
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.2",
                    "IPAMConfig": null,
                    "IPAddress": "172.17.0.2",

```

Т.о. html-страница доступа по адресу 172.17.0.2.

Загрузим созданный образ в docker hub:

```
$ docker login
$ docker push johntux/task-15
```

* [johntux/task-15](https://hub.docker.com/r/johntux/task-15) - ссылка на репозиторий с образом.

Образ - это файл в режиме только "чтение".

Контейнер - файл, последний слой которого открыт на чтение и запись.

~~В контейнере собрать ядро нельзя, т.к. он использует ресурсы (ядро, память) хост-машины.~~ Комментарий преподавателя:

"Ядро можно собрать в контейнере, вот только запуститься с него не получится. Такой вариант уместен в том случае, если мы не хотим в хостовую систему добавлять лишние пакеты."