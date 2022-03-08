# Домашнее задание к занятию "6.3. MySQL"
## Задача 1
Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в `volume`.

Изучите бэкап БД и восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и приведите в ответе из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

Приведите в ответе количество записей с `price > 300`.
## Решение:
Версия сервера БД:
```
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
```
Список таблиц БД `test_db`
```
mysql> SELECT table_name FROM test_db.tables;
ERROR 1146 (42S02): Table 'test_db.tables' doesn't exist
mysql> SELECT table_name FROM information_schema.tables
    -> WHERE table_schema = 'test_db';
+------------+
| TABLE_NAME |
+------------+
| orders     |
+------------+
1 row in set (0.00 sec)
```
Количество записей с `price > 300`
```
mysql> SELECT * FROM orders WHERE price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```
## Задача 2
Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации `mysql_native_password`
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:  
Фамилия "Pretty"  
Имя "James"

Предоставьте привелегии пользователю `test` на операции `SELECT` базы `test_db`.

Используя таблицу `INFORMATION_SCHEMA.USER_ATTRIBUTES` получите данные по пользователю `test` и приведите в **ответе к задаче**.
## Решение:
```
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';
+------+------+------------------------------------------------+
| USER | HOST | ATTRIBUTE                                      |
+------+------+------------------------------------------------+
| test | %    | {"last_name": "Pretty", "first_name": "James"} |
+------+------+------------------------------------------------+
1 row in set (0.01 sec)
```
## Задача 3
Установите профилирование `SET profiling = 1`. Изучите вывод профилирования команд `SHOW PROFILES`;.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и приведите время выполнения и запрос на изменения из профайлера в ответе:

- на MyISAM
- на InnoDB
## Решение:
Используется `engine` `InnoDB`
```
mysql> SELECT TABLE_NAME,
    ->        ENGINE
    -> FROM   information_schema.TABLES
    -> WHERE  TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.01 sec)
```
Время выполнения изменения `engine` на `MyISAM` и запрос из профайлера:
```
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                                         |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------+     |
|        7 | 0.17131850 | ALTER TABLE orders ENGINE = MyISAM                                                                                            |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------+

```
Время выполнения изменения `engine` на `InnoDB` и запрос из профайлера:
```
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                                         |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------+                                                                                           |
|        8 | 0.11375250 | ALTER TABLE orders ENGINE = InnoDB                                                                                            |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------+
```
# Задача 4
Изучите файл my.cnf в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл my.cnf.

## Решение:
- Скорость IO важнее сохранности данных - `innodb_flush_log_at_trx_commit=2`. Настройка контролирует баланс между строгим соответствием ACID для операций фиксации и более высокой производительностью, которая возможна, когда операции ввода-вывода, связанные с фиксацией, переупорядочиваются и выполняются пакетами. Можно повысить производительность, изменив значение по умолчанию `1`, но тогда можно потерять транзакции в случае сбоя.  
При значении `2` журналы записываются после каждой фиксации транзакции и сбрасываются на диск один раз в секунду. Транзакции, журналы которых не были очищены, могут быть потеряны в результате сбоя.
- Нужна компрессия таблиц для экономии места на диске - в MySQL 8 для поддержки компрессии необходимо включить параметры `innodb_file_per_table=1` и `innodb_default_row_format=COMPRESSED`.
- Размер буффера с незакомиченными транзакциями 1 Мб - настройка `innodb_log_buffer_size=1048576`. Размер в байтах буфера InnoDB используемого для записи файлов журнала на диск. По умолчанию 16 МБ. Большой буфер журнала позволяет выполнять большие транзакции без необходимости записи журнала на диск перед фиксацией транзакции.
- Буффер кеширования 30% от ОЗУ - параметр `innodb_buffer_pool_size = 926743552` - размер в байтах (в моем случае 30% от общего объема ОЗУ) объема оперативной памяти, отведенной InnoDB для хранения таблиц и индексов.
- Размер файла логов операций 100 Мб - параметр `innodb_log_file_size=104857600` - размер в байтах файла журнала операций.

Листинг файла `my.conf`:
```
root@634a51d18eeb:~# cat /etc/mysql/my.cnf
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/
innodb_flush_log_at_trx_commit=2
innodb_file_per_table=1
innodb_default_row_format=COMPRESSED
innodb_log_buffer_size=1048576
innodb_buffer_pool_size = 926743552
innodb_log_file_size=104857600
```
