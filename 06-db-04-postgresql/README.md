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

## Решение:
Изначально для исключения "ручного" разбиения можно было бы спроектировать таблицу по методу декларативного секционирования, либо по методу секционирования с использованием наследования.  

Так как шардирование нельза сделать на уже существующую таблицу, необходимо создать новую таблицу с шардированием и перенести в нее данные из старой таблицы.  
Я выбрал метод декларативного шардирования.  
SQL-транзакция:
```sql
-- начинаем транзакцию
BEGIN;
-- переименовываем существующую таблицу
ALTER TABLE orders RENAME TO orders_old;
-- создаем новую таблицу с полями как у старой, но с шардингом по полю price
CREATE TABLE orders (LIKE orders_old INCLUDING DEFAULTS) PARTITION BY RANGE (price);
-- даем права на таблицу
ALTER TABLE orders OWNER TO postgres;
-- переназначаем последовательность на новую таблицу
ALTER SEQUENCE orders_id_seq OWNED BY orders.id;
-- создаем секцию, которая будет принимать любые значения больше 499
CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (500) TO (MAXVALUE);
-- создаем секцию, которая будет принимать любые значения меньше либо равные 499
CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (MINVALUE) TO (500);
-- переносим данные в новую таблицу с шардингом
INSERT INTO orders (id, title, price) SELECT * FROM orders_old;
-- удаляем старую таблицу
DROP TABLE orders_old;
-- записываем транзакцию
COMMIT;
```
Проверяем, что таблица `orders` с щардингом и по запросу выдает запрашиваемые данные:
```
test_database=# \d+
                                       List of relations
 Schema |     Name      |       Type        |  Owner   | Persistence |    Size    | Description 
--------+---------------+-------------------+----------+-------------+------------+-------------
 public | orders        | partitioned table | postgres | permanent   | 0 bytes    | 
 public | orders_1      | table             | postgres | permanent   | 8192 bytes | 
 public | orders_2      | table             | postgres | permanent   | 8192 bytes | 
 public | orders_id_seq | sequence          | postgres | permanent   | 8192 bytes | 
(4 rows)

test_database=# SELECT * FROM orders;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

```
Данные в секциях таблицы разделяются согласно условию `price > 499` и `price <= 499`:
```
est_database=# SELECT * FROM orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```
Если мы добавляем данные в таблицу `orders`, то они добавляются в необходимую секцию. Генерация последовательности так же работает:
```
test_database=# INSERT INTO orders (title, price) VALUES ('test', 600);
INSERT 0 1
test_database=# SELECT * FROM orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
  9 | test               |   600
(4 rows)

test_database=# SELECT * FROM orders;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
  9 | test                 |   600
(9 rows)

test_database=# SELECT * FROM orders_id_seq;
 last_value | log_cnt | is_called 
------------+---------+-----------
          9 |      32 | t
(1 row)
```

## Задача 4
Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

## Решение:
Создаем дамп базы `test_database`:
```
root@eae37291d531:/# pg_dump -U postgres test_database > /backups/test_db_dump.sql
```
Дорабатываем бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`:  
В секционированных таблицах можно создавать индексы и уникальные ключи так, чтобы они применялись автоматически ко всей иерархии.  
Это очень удобно, так как индексироваться будут не только все существующие секции, но и любые секции, создаваемые в будущем.  
Но есть одно ограничение — такой секционированный индекс нельзя создать в неблокирующем режиме. Чтобы избежать блокировки на долгое время, для создания индекса в самой секционированной таблице можно использовать команду CREATE INDEX ON ONLY (то же касается и UNIQUE);  
такой индекс будет помечен как нерабочий, и он не будет автоматически применён к секциям. Индексы собственно в секциях можно создать в индивидуальном порядке, а затем присоединить их к индексу родителя, используя команду ALTER INDEX .. ATTACH PARTITION.  
После того как индексы всех секций будут присоединены к родительскому, последний автоматически перейдёт в рабочее состояние.
Поэтому в дамп нужно добавить следующее:
```
ALTER TABLE ONLY orders ADD UNIQUE (title, price);
ALTER TABLE orders_1 ADD UNIQUE (title, price);
ALTER INDEX orders_title_price_key
    ATTACH PARTITION orders_1_title_price_key;
ALTER TABLE orders_2 ADD UNIQUE (title, price);
ALTER INDEX orders_title_price_key
    ATTACH PARTITION orders_2_title_price_key;
```