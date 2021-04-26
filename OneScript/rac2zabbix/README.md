Синхронизация Zabbix с сервером администрирования кластера серверов 1С
======================================================================

Оглавление
==========

- [Описание](#Описание)
- [Установка](#установка)
- [Запуск тестов](#тетсы)

## Описание

rac2zabbix - предназначена для получения аналитической информации о текущем состоянии и загруженности серверов 1С.
Данные выводятся в стандартный поток вывода и в кодировке 65001 и анализируются zabbix

## Установка

1. Установка onescript
Скачать и установить свежую версию Onescript
Версия Onescript должна быть 32 разрядной, т.к. библиотека sql из репозитория
onescript использует 32 разрядную сборку dll
https://oscript.io/downloads

2. Клонировать проек rac2zabbix в локальный репозиторий
>git clone /path/to/repo

3. Перейти в каталог проекта
>cd path/to/rac2zabbix

4. Выполнить сборку проекта
>opm build .

5. Установить проект
>opm install -f [имя .ospx файла].ospx (ospx файл создается командой build)

6. Добавить в конфигурационный файл zabbix агента строки
```
Timeout=30
UserParameter=1c.infobases.discovery[\*],rac2zabbix discovery -host localhost -port $1 -user $2 -password $3
UserParameter=1c.infobases.info[\*],rac2zabbix infobase -host localhost -port $1 -cluster $2 -infobase $3 -user $4 -password $5
UserParameter=1c.servers.discovery[\*],rac2zabbix discovery-cluster-servers -host localhost -port $1 -user $2 -password $3
UserParameter=1c.servers.processes[\*],rac2zabbix process-list -host localhost -port $1 -cluster $2 -agent-host $3 -user $4 -password $5
UserParameter=1c.clusters.discovery[\*],rac2zabbix discovery-clusters -host localhost -port $1
UserParameter=1c.clusters.processes[\*],rac2zabbix processes -host localhost -port $1 -cluster $2 -user $3 -password $4
UserParameter=1c.clusters.sessions[\*],rac2zabbix sessions -host localhost -port $1 -cluster $2 -user $3 -password $4
```
7. Перезапустить службу zabbix_agent

8. Добавить в zabbix шаблон элементов из каталога ./templates

## Запуск тестов

Установка 1testrunner:
> opm install 1testrunner

Запуск тестов:
> 1testrunner -runall [Путь к библиотеке]/tests

Запустить тесты можно из редактора VS Code
F1 > Tasks:Run Tasks > Show all tasks... > cmd: 1testrunner: Testing project
