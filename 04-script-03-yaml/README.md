### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис
### Решение:
Не хватает `"` после `ip`, так как ключ должен быть заключен в двойные кавычки. IP адрес тоже нужно заключить в двойные кавычки в строке `"ip : 71.78.22.43`. Правильный код:
``` json
{ "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket  # модуль нужен для работы с сокетами
import time  # модуль нужен для отсчета времени
import yaml  # модуль нужен для работы с файлами yaml
import json  # модуль нужен для работы с файлами json

hosts_names = ["drive.google.com", "mail.google.com", "google.com"]  # создаю список названий хостов
hosts_ip = {}  # создаю пустой первый словарь
for host in hosts_names:  # для каждого имени хоста в первый раз...
    # ip = socket.gethostbyname(host)
    hosts_ip[host] = socket.gethostbyname(host)  # ...сопоставляю  имя хоста и его IP адрес, записываю в словарь

while True:  # делаю бесконечный цикл
    new_hosts = hosts_ip.copy()  # копирую в новый словарь имя хоста и его IP адрес для дальнейшего сравнения
    for host, ip in hosts_ip.items():  # для первого словаря проверяю...
        # ip = socket.gethostbyname(host)
        new_hosts[host] = socket.gethostbyname(host)  # ... запрашиваю во втором словаре, не изменился ли IP у хоста?
        # print(new_hosts[ip])
        if new_hosts[host] == ip:  # если не изменился, то...
            print(host + ' - ' + ip)  # ... вывожу соответствующее сообщение
        else:  # иначе...
            print("[ERROR] " + host + " IP mismatch: " + ip + " " + new_hosts[host])  # ...вывожу другое сообщение
            hosts_ip[host] = new_hosts[host]  # ...и перезаписываю первый словарь новыми данными

    json_data = open("json_data.json", "w")  # открываю на запись файл json
    yaml_data = open("yaml_data.yaml", "w")  # открываю на запись файл yaml
    for host, ip in new_hosts.items():  # для вывода каждого хоста и IP адреса согласно шаблону задания
        new_hosts = {host: ip}  # приведу каждую запись к такому виду
        json.dump(new_hosts, json_data)  # записываю новые данные в файл json в формате { "имя сервиса" : "его IP"}
        yaml.dump([new_hosts], yaml_data)  # записываю новые данные в файл yaml в формате - имя сервиса: его IP
    json_data.close()  # закрываю файл json
    yaml_data.close()  # закрываю файл yaml
    time.sleep(5)  # торможу работу скрипта на 5 секунд
```

### Вывод скрипта при запуске при тестировании:
```
C:\Users\GreyPaw\AppData\Local\Programs\Python\Python310\python.exe C:/Users/GreyPaw/Documents/script7.py
drive.google.com - 142.250.150.194
mail.google.com - 74.125.205.19
google.com - 74.125.131.102
drive.google.com - 142.250.150.194
[ERROR] mail.google.com IP mismatch: 74.125.205.19 74.125.205.83
[ERROR] google.com IP mismatch: 74.125.131.102 74.125.131.113
Traceback (most recent call last):
  File "C:\Users\GreyPaw\Documents\script7.py", line 34, in <module>
    time.sleep(5)  # торможу работу скрипта на 5 секунд
KeyboardInterrupt

Process finished with exit code -1073741510 (0xC000013A: interrupted by Ctrl+C)
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "142.250.150.194"}{"mail.google.com": "74.125.205.83"}{"google.com": "74.125.131.113"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
- drive.google.com: 142.250.150.194
- mail.google.com: 74.125.205.83
- google.com: 74.125.131.113
```