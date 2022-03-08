# Домашнее задание к занятию "6.4. PostgreSQL"
## Задача 1
Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в `volume`.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

Найдите и приведите управляющие команды для:

- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

## Решение:
Вывод списка БД:
```
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```
Подключение к БД:
```
postgres=# \c postgres
You are now connected to database "postgres" as user "postgres".
```
Вывод списка таблиц:
```
template1=# \dt
```
Для вывода списка системных таблиц следует использовать команду `\dtS`
Вывод описания содержимого таблиц:
Команда `\d+` выведет описание содержимого таблиц.
Команда `\dS+` выведет описание содержимого системных таблиц.
Выход из `psql`:
```
postgres=# \q
```

## Задача 2
Используя `psql` создайте БД `test_database`.

Изучите бэкап БД.

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию `ANALYZE` для сбора статистики по таблице.

Используя таблицу `pg_stats`, найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.

Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.

## Решение:
Создаем БД `test_database`:
```
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
```
Восстанавливаем дамп в базу:
```
root@eae37291d531:/# psql -U postgres test_database < /backups/test_dump.sql 
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```
В таблице `pg_stats` в столбце `attname` находится имя столбца таблицы, по которой ведется статистика, а в `avg_width` находятся значения среднего размера элементов в столбце, в байтах. Команда вывода наибольшего среднего значения:
```
test_database=# select attname, avg_width from pg_stats where tablename='orders' ORDER BY avg_width DESC;
 attname | avg_width 
---------+-----------
 title   |        16
 id      |         4
 price   |         4
(3 rows)
```
Из результата следует, что в таблице `orders` с наибольшим средним значением размера элементов является столбец `title`.

##  Задача 3
Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?