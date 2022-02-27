# Домашнее задание к занятию "6.2. SQL"
## Задача 1
Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

## Решение:
```
version: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ../2. Init Database:/docker-entrypoint-initdb.d
      - data-vol:/var/lib/postgresql/data/
      - backup-vol:/backups
    ports:
      - "5432:5432"
volumes:
  data-vol: {}
  backup-vol: {}

```
## Задача 2
## Решение:
Итоговый список БД после выполнения пунктов:
```
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges        
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```
Описание таблиц (describe):
```
test_db=# \d+ orders
                                                   Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------------+---------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 наименование | text    |           |          |                                    | extended |              | 
 цена         | integer |           |          |                                    | plain    |              | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```
```
test_db=# \d+ clients
                                                      Table "public.clients"
      Column       |  Type   | Collation | Nullable |               Default               | Storage  | Stats target | Description 
-------------------+---------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer |           | not null | nextval('clients_id_seq'::regclass) | plain    |              | 
 фамилия           | text    |           |          |                                     | extended |              | 
 страна проживания | text    |           |          |                                     | extended |              | 
 заказ             | integer |           |          |                                     | plain    |              | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_страна проживания_idx" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```
SQL-запрос просмотра прав пользователей на таблицы базы test_db:
```
test_db=# SELECT * FROM \dp 
                                           Access privileges
 Schema |      Name      |   Type   |         Access privileges          | Column privileges | Policies 
--------+----------------+----------+------------------------------------+-------------------+----------
 public | clients        | table    | postgres=arwdDxt/postgres         +|                   | 
        |                |          | "test-simple-user"=arwd/postgres  +|                   | 
        |                |          | "test-admin-user"=arwdDxt/postgres |                   | 
 public | clients_id_seq | sequence |                                    |                   | 
 public | orders         | table    | postgres=arwdDxt/postgres         +|                   | 
        |                |          | "test-simple-user"=arwd/postgres  +|                   | 
        |                |          | "test-admin-user"=arwdDxt/postgres |                   | 
 public | orders_id_seq  | sequence |                                    |                   | 
(4 rows)
```
Видно, что у пользователя `test-admin-user` полные права `arwdDxt`, а у пользователя `test-simple-user` прав меньше `arwd`, где:
- a – insert;
- r – select;
- w – update;
- d – delete;
- D – truncate;
- x – reference;
- t – trigger.

## Задача 3
Используя SQL синтаксис - наполните таблицы следующими тестовыми данными

## Решение:
```
test_db=# INSERT INTO orders ("наименование", "цена") VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000), ('Гитара', 4000);
INSERT 0 5
```
```
test_db=# INSERT INTO clients ("фамилия", "страна проживания") VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada'), ('Иоганн Себастьян Бах', 'Japan'), ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');
INSERT 0 5
```
```
test_db=# \timing on
Timing is on.
test_db=# SELECT count(*) FROM orders;
 count 
-------
     5
(1 row)

Time: 0.377 ms
```
```
test_db=# SELECT count(*) FROM clients;
 count 
-------
     5
(1 row)

Time: 0.292 ms
```
## Задача 4
Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

```
ФИО	                Заказ
Иванов Иван Иванович	Книга
Петров Петр Петрович	Монитор
Иоганн Себастьян Бах	Гитара
```
Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

## Решение:
```
UPDATE clients set "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Книга') WHERE clients."фамилия" = 'Иванов Иван Иванович';
```
```
UPDATE clients set "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Монитор') WHERE clients."фамилия" = 'Петров Петр Петрович';
```
```
UPDATE clients set "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Гитара') WHERE clients."фамилия" = 'Иоганн Себастьян Бах';
```
```
test_db=# SELECT "фамилия" FROM clients WHERE "заказ" IS NOT NULL;
       фамилия        
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)

Time: 0.401 ms

```
## Задача 5
Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Решение:
```
test_db=# EXPLAIN SELECT "фамилия" FROM clients WHERE "заказ" IS NOT NULL;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=32)
   Filter: ("заказ" IS NOT NULL)
(2 rows)

Time: 43.230 ms
```
После успешного выполнения запроса с ключом EXPLAIN возвращается вся статистика времени выполнения, включая полное время на каждый узел плана и общее число строк, прочитанных запросом.

Параметр `costs=0.00` - приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных, например для сортирующего узла это время сортировки.

Параметр `costs=18.10` - приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки.

`rows=806 ` - ожидаемое число строк, которое должен вывести этот узел плана.

`width=32` - ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).

## Задача 6
Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.

## Решение:
Для создания бэкапа базы `test_db` использовал утилиту pg_dump.  
В параметрах команды указывал имя пользователя, под которым производится подключение к postgres.
```
root@9c3f3fdda36f:/# pg_dump -U postgres test_db > /backups/test_db_dump
```
Далее запустил второй контейнер с `postgres` посредством `docker-compose`. В листинге yml-файла подключил директорию с бэкапом базы `test_db`.  

Перед восстановлением во втором контейнере бэкапа базы `tesd_db`, её необходимо создать.  
Далее посредством `psql` восстанавливаю бэкап базы `test_db`.  
```
root@4cf002a67a54:/# psql -U postgres test_db < /backups/_data/test_db_dump
```

