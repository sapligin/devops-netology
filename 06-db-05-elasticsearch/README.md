# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

Используя докер образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к elasticsearch.yml:

- данные path должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:

- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ elasticsearch на запрос пути / в json виде

## Решение:
Dockerfile-манифест для elasticsearch:
```
FROM centos:centos7

RUN yum makecache && \
    yum -y install wget && \
    yum -y install perl-Digest-SHA

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.2-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.2-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.1.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.1.2-linux-x86_64.tar.gz && \
    cd elasticsearch-8.1.2/

RUN groupadd -g 1000 elastic && useradd elastic -u 1000 -g 1000 && \
	chown -R elastic:elastic /elasticsearch-8.1.2 && \ 
	chmod o+x /elasticsearch-8.1.2 
	
RUN mkdir -p /var/lib/elasticsearch/data/ && \ 
	chown -R elastic:elastic /var/lib/elasticsearch/
    
COPY elasticsearch.yml /elasticsearch-8.1.2/config/     
    
USER elastic

CMD ["/elasticsearch-8.1.2/bin/elasticsearch"]

EXPOSE 9200 9300
```
[Ссылка на образ на hub.docker.com](https://hub.docker.com/repository/docker/sapligin/elasticsearch)

elasticsearch.yml:
```
node.name: netology_test
path.data: /var/lib/elasticsearch/data/
http.port: 9200
```
Ответ elasticsearch на запрос пути `/` в json виде
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic https://localhost:9200
Enter host password for user 'elastic':
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "NqfrtcNmTP67ieaMEQTVXw",
  "version" : {
    "number" : "8.1.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "31df9689e80bad366ac20176aa7f2371ea5eb4c1",
    "build_date" : "2022-03-29T21:18:59.991429448Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2
Ознакомьтесь с документацией и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |
Получите список индексов и их статусов, используя API и приведите в ответе на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии `yellow`?

Удалите все индексы.

## Решение:
Добавляем индексы командами
```
curl -ku elastic -X PUT "https://localhost:9200/ind-1" -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
curl -ku elastic -X PUT "https://localhost:9200/ind-2" -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'
curl -ku elastic -X PUT "https://localhost:9200/ind-3" -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
```
Список индексов и их статусы:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X GET "https://localhost:9200/_cat/indices?v"
Enter host password for user 'elastic':
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 kB8bNHlVR3W3N8JHUK0eEA   1   0          0            0       225b           225b
yellow open   ind-3 VTYewp4ARnGfA8jZi_k-BA   4   2          0            0       900b           900b
yellow open   ind-2 efQWPhW3S-2Qp5sXdnle5Q   2   1          0            0       450b           450b
```
Состояние кластера `elasticsearch`:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X GET "https://localhost:9200/_cluster/health?pretty"
Enter host password for user 'elastic':
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 9,
  "active_shards" : 9,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
}
```
Часть индексов и кластер находится в состоянии `yellow`, потому что этим индексам мы назначили реплики, а реплик на самом деле не существует. Кластер сигнализирует, что если нода выйдет из строя, часть данных будет недоступна.

Удаляем индексы:
```
curl -ku elastic -X DELETE "https://localhost:9200/ind-1"
curl -ku elastic -X DELETE "https://localhost:9200/ind-2"
curl -ku elastic -X DELETE "https://localhost:9200/ind-3"
```

## Задача 3

Создайте директорию {путь до корневой директории с elasticsearch в образе}/snapshots.

Используя API зарегистрируйте данную директорию как snapshot repository c именем netology_backup.

Приведите в ответе запрос API и результат вызова API для создания репозитория.

Создайте индекс test с 0 реплик и 1 шардом и приведите в ответе список индексов.

Создайте snapshot состояния кластера elasticsearch.

Приведите в ответе список файлов в директории со snapshotами.

Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.

Восстановите состояние кластера elasticsearch из snapshot, созданного ранее.

Приведите в ответе запрос к API восстановления и итоговый список индексов.

##  Решение:
Запрос API и результат вызова API для создания репозитория:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X PUT "https://localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/elasticsearch-8.1.2/snapshots/"
  }
}
'
Enter host password for user 'elastic':
{
  "acknowledged" : true
}
```
Список индексов `test`:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X GET "https://localhost:9200/_cat/indices?v"
Enter host password for user 'elastic':
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  R81SBwFnSAeiwHXlZMBplQ   1   0          0            0       225b           225b
```
Делаем snapshot:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X PUT "https://localhost:9200/_snapshot/netology_backup/elastic_snapshot"
Enter host password for user 'elastic':
{"accepted":true}
```
Список файлов в директории со snapshotами:
```
[elastic@972fcaa2c859 snapshots]$ ls -l
total 36
-rw-r--r-- 1 elastic elastic  1101 Apr  9 11:04 index-0
-rw-r--r-- 1 elastic elastic     8 Apr  9 11:04 index.latest
drwxr-xr-x 5 elastic elastic  4096 Apr  9 11:04 indices
-rw-r--r-- 1 elastic elastic 18350 Apr  9 11:04 meta-Xi69TQLIR4qmssDeXdBv1A.dat
-rw-r--r-- 1 elastic elastic   388 Apr  9 11:04 snap-Xi69TQLIR4qmssDeXdBv1A.dat
```
Удаляем индекс `test` исоздаем индекс `test-2`. Список с индексом `test-2`:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X GET "https://localhost:9200/_cat/indices?v"
Enter host password for user 'elastic':
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 f6J8QVdYQreMzTgSCBSivw   1   0          0            0       225b           225b
```

Для восстановления всего кластера необходимо временно остановить индексирование и отключить следующие функции:
- GeoIP database downloader
- ILM
- Machine Learning
- Monitoring
- Watcher

Иначе, в моем случае, индекс `test` восстанавливался со статусом `RED`

Запрос к API восстановления и итоговый список индексов:
```
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X POST "https://localhost:9200/_snapshot/netology_backup/elastic_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "*",
  "include_global_state": true
}
'
Enter host password for user 'elastic':
{
  "accepted" : true
}
pligin@ubuntu:~/Documents/06-db-05-elasticsearch$ curl -ku elastic -X GET "https://localhost:9200/_cat/indices?v"
Enter host password for user 'elastic':
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 f6J8QVdYQreMzTgSCBSivw   1   0          0            0       225b           225b
green  open   test   R81SBwFnSAeiwHXlZMBplQ   1   0          0            0       225b           225b
```