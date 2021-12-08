# devops-netology Плигин Сергей
## Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

#### 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
#### Решение:
В Linux список сетевых интерфейсов можно посмотреть командой `ip -c -br link`  

    vagrant@vagrant:~$ ip -c -br link  
    lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>  
    eth0             UP             08:00:27:73:60:cf <BROADCAST,MULTICAST,UP,LOWER_UP>  
В Windows список сетевых интерфейсов можно посмотреть командой `ipconfig /all` или командой `netsh interface show interface` или командой PowerShell `Get-NetAdapter`  

    PS C:\Windows\system32> Get-NetAdapter

    Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
    ----                      --------------------                    ------- ------       ----------             ---------
    Сетевое подключение Bl... Bluetooth Device (Personal Area Netw...      23 Disconnected 7C-50-79-3C-0F-36         3 Mbps
    Подключение по локальн... TAP-Windows Adapter V9                       17 Not Present  00-FF-9F-55-6F-30          0 bps
    Ethernet                  Realtek PCIe GbE Family Controller           13 Disconnected 38-F3-AB-6B-59-02          0 bps
    VMware Network Adapte...8 VMware Virtual Ethernet Adapter for ...      10 Up           00-50-56-C0-00-08       100 Mbps
    VirtualBox Host-Only N... VirtualBox Host-Only Ethernet Adapter         9 Up           0A-00-27-00-00-09         1 Gbps
    Беспроводная сеть         Intel(R) Wi-Fi 6 AX201 160MHz                 6 Up           7C-50-79-3C-0F-32     144.4 Mbps
    VMware Network Adapte...1 VMware Virtual Ethernet Adapter for ...       4 Up           00-50-56-C0-00-01       100 Mbps
    VPN - VPN Client          VPN Client Adapter - VPN                      3 Disconnected 5E-68-F0-78-C6-37       100 Mbps
#### 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
#### Решение:
Link Layer Discovery Protocol (LLDP) — протокол канального уровня, который позволяет сетевым устройствам анонсировать в сеть информацию о себе и о своих возможностях, а также собирать эту информацию о соседних устройствах.  
В Linux есть пакет `lldpd` для работы с данным протоколом.  
Команда для работы с протоколом LLDP - `lldpctl`
#### 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.
#### Решение:
Для разделения L2 коммутатора на несколько виртуальных сетей используется технология VLAN.  
В Linux для этого необходимо установить пакет `vlan`.  
Настройки подинтерфейсов VLAN указываются в файле /etc/network/interfaces.  

    vagrant@vagrant:~$ cat /etc/network/interfaces
    auto vlan1400
    iface vlan1400 inet static
        address 192.168.1.1
        netmask 255.255.255.0
        vlan_raw_device eth0
#### 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.
#### Решение:
В Linux есть статические и динамические типы агрегации интерфейсов.  
Linux поддерживает следующие опции балансиировки нагрузки:

- 0 (balance-rr) — круговое распределение пакетов между интерфейсами. Обеспечивает отказоустойчивость и повышение пропускной способности.
- 1 (active-backup) — в каждый момент времени работает только один интерфейс, в случае его выхода из строя, mac-адрес назначается второму интерфейсу и трафик переключается на него.
- 2 (balance-xor) — обеспечивает балансировку между интерфейсами на основании MAC-адресов отправителя и получателя.
- 3 (broadcast) — отправляет пакеты через все интерфейсы одновременно, обеспечивает отказоустойчивость.
- 4 (802.3ad) — обеспечивает агрегацию на основании протокола 802.3ad.
- 5 (balance-tlb) — в этом режиме входящий трафик приходит только на один «активный» интерфейс, исходящий же распределяется по всем интерфейсам.
- 6 (balance-alb) — балансирует исходящий трафик как tlb, а так же входящий IPv4 трафик используя ARP.  
Для использования агрегации интерфейсов в Linux необходимо установить пакет `ifenslave` для управления агрегацией, и включить в ядре Linux модуль бондинга командой `modprobe bonding`


    vagrant@vagrant:~$ cat /etc/network/interfaces
    # eth0 настраивается вручную и подчиняется привязанной сетевой карте "bond0"
    auto eth0
    iface eth0 inet manual
        bond-master bond0
        bond-primary eth0

    # eth1, создаем связь с bond0.
    auto eth1
    iface eth1 inet manual
        bond-master bond0

    # bond0 - это связывающая сетевая карта, которую можно использовать как любую другую обычную сетевую карту.
    # bond0 настроен с использованием статической сетевой информации.
    auto bond0
    iface bond0 inet static
        address 192.168.1.10
        gateway 192.168.1.1
        netmask 255.255.255.0
        bond-mode active-backup
        bond-miimon 100
        bond-slaves none
#### 5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
#### Решение:
В сети с маской /29 6 IP адресов  

    vagrant@vagrant:~$ ipcalc 192.168.1.1/29
    Address:   192.168.1.1          11000000.10101000.00000001.00000 001
    Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
    Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
    =>
    Network:   192.168.1.0/29       11000000.10101000.00000001.00000 000
    HostMin:   192.168.1.1          11000000.10101000.00000001.00000 001
    HostMax:   192.168.1.6          11000000.10101000.00000001.00000 110
    Broadcast: 192.168.1.7          11000000.10101000.00000001.00000 111
    Hosts/Net: 6                     Class C, Private Internet
Из сети с маской /24 можно получить 32 подсети с маской /29

    vagrant@vagrant:~$ ipcalc -b 192.168.1.0/24 29
    Address:   192.168.1.0
    Netmask:   255.255.255.0 = 24
    Wildcard:  0.0.0.255
    =>
    Network:   192.168.1.0/24
    HostMin:   192.168.1.1
    HostMax:   192.168.1.254
    Broadcast: 192.168.1.255
    Hosts/Net: 254                   Class C, Private Internet
    
    Subnets after transition from /24 to /29
    
    Netmask:   255.255.255.248 = 29
    Wildcard:  0.0.0.7

    1.
    Network:   192.168.1.0/29
    HostMin:   192.168.1.1
    HostMax:   192.168.1.6
    Broadcast: 192.168.1.7
    Hosts/Net: 6                     Class C, Private Internet

    2.
    Network:   192.168.1.8/29
    HostMin:   192.168.1.9
    HostMax:   192.168.1.14
    Broadcast: 192.168.1.15
    Hosts/Net: 6                     Class C, Private Internet

    3.
    Network:   192.168.1.16/29
    HostMin:   192.168.1.17
    HostMax:   192.168.1.22
    Broadcast: 192.168.1.23
    Hosts/Net: 6                     Class C, Private Internet

    4.
    Network:   192.168.1.24/29
    HostMin:   192.168.1.25
    HostMax:   192.168.1.30
    Broadcast: 192.168.1.31
    Hosts/Net: 6                     Class C, Private Internet

    5.
    Network:   192.168.1.32/29
    HostMin:   192.168.1.33
    HostMax:   192.168.1.38
    Broadcast: 192.168.1.39
    Hosts/Net: 6                     Class C, Private Internet

    6.
    Network:   192.168.1.40/29
    HostMin:   192.168.1.41
    HostMax:   192.168.1.46
    Broadcast: 192.168.1.47
    Hosts/Net: 6                     Class C, Private Internet

    7.
    Network:   192.168.1.48/29
    HostMin:   192.168.1.49
    HostMax:   192.168.1.54
    Broadcast: 192.168.1.55
    Hosts/Net: 6                     Class C, Private Internet

    8.
    Network:   192.168.1.56/29
    HostMin:   192.168.1.57
    HostMax:   192.168.1.62
    Broadcast: 192.168.1.63
    Hosts/Net: 6                     Class C, Private Internet

    9.
    Network:   192.168.1.64/29
    HostMin:   192.168.1.65
    HostMax:   192.168.1.70
    Broadcast: 192.168.1.71
    Hosts/Net: 6                     Class C, Private Internet

    10.
    Network:   192.168.1.72/29
    HostMin:   192.168.1.73
    HostMax:   192.168.1.78
    Broadcast: 192.168.1.79
    Hosts/Net: 6                     Class C, Private Internet

    11.
    Network:   192.168.1.80/29
    HostMin:   192.168.1.81
    HostMax:   192.168.1.86
    Broadcast: 192.168.1.87
    Hosts/Net: 6                     Class C, Private Internet

    12.
    Network:   192.168.1.88/29
    HostMin:   192.168.1.89
    HostMax:   192.168.1.94
    Broadcast: 192.168.1.95
    Hosts/Net: 6                     Class C, Private Internet

    13.
    Network:   192.168.1.96/29
    HostMin:   192.168.1.97
    HostMax:   192.168.1.102
    Broadcast: 192.168.1.103
    Hosts/Net: 6                     Class C, Private Internet

    14.
    Network:   192.168.1.104/29
    HostMin:   192.168.1.105
    HostMax:   192.168.1.110
    Broadcast: 192.168.1.111
    Hosts/Net: 6                     Class C, Private Internet

    15.
    Network:   192.168.1.112/29
    HostMin:   192.168.1.113
    HostMax:   192.168.1.118
    Broadcast: 192.168.1.119
    Hosts/Net: 6                     Class C, Private Internet

    16.
    Network:   192.168.1.120/29
    HostMin:   192.168.1.121
    HostMax:   192.168.1.126
    Broadcast: 192.168.1.127
    Hosts/Net: 6                     Class C, Private Internet

    17.
    Network:   192.168.1.128/29
    HostMin:   192.168.1.129
    HostMax:   192.168.1.134
    Broadcast: 192.168.1.135
    Hosts/Net: 6                     Class C, Private Internet

    18.
    Network:   192.168.1.136/29
    HostMin:   192.168.1.137
    HostMax:   192.168.1.142
    Broadcast: 192.168.1.143
    Hosts/Net: 6                     Class C, Private Internet

    19.
    Network:   192.168.1.144/29
    HostMin:   192.168.1.145
    HostMax:   192.168.1.150
    Broadcast: 192.168.1.151
    Hosts/Net: 6                     Class C, Private Internet

    20.
    Network:   192.168.1.152/29
    HostMin:   192.168.1.153
    HostMax:   192.168.1.158
    Broadcast: 192.168.1.159
    Hosts/Net: 6                     Class C, Private Internet

    21.
    Network:   192.168.1.160/29
    HostMin:   192.168.1.161
    HostMax:   192.168.1.166
    Broadcast: 192.168.1.167
    Hosts/Net: 6                     Class C, Private Internet

    22.
    Network:   192.168.1.168/29
    HostMin:   192.168.1.169
    HostMax:   192.168.1.174
    Broadcast: 192.168.1.175
    Hosts/Net: 6                     Class C, Private Internet

    23.
    Network:   192.168.1.176/29
    HostMin:   192.168.1.177
    HostMax:   192.168.1.182
    Broadcast: 192.168.1.183
    Hosts/Net: 6                     Class C, Private Internet

    24.
    Network:   192.168.1.184/29
    HostMin:   192.168.1.185
    HostMax:   192.168.1.190
    Broadcast: 192.168.1.191
    Hosts/Net: 6                     Class C, Private Internet

    25.
    Network:   192.168.1.192/29
    HostMin:   192.168.1.193
    HostMax:   192.168.1.198
    Broadcast: 192.168.1.199
    Hosts/Net: 6                     Class C, Private Internet

    26.
    Network:   192.168.1.200/29
    HostMin:   192.168.1.201
    HostMax:   192.168.1.206
    Broadcast: 192.168.1.207
    Hosts/Net: 6                     Class C, Private Internet

    27.
    Network:   192.168.1.208/29
    HostMin:   192.168.1.209
    HostMax:   192.168.1.214
    Broadcast: 192.168.1.215
    Hosts/Net: 6                     Class C, Private Internet

    28.
    Network:   192.168.1.216/29
    HostMin:   192.168.1.217
    HostMax:   192.168.1.222
    Broadcast: 192.168.1.223
    Hosts/Net: 6                     Class C, Private Internet

    29.
    Network:   192.168.1.224/29
    HostMin:   192.168.1.225
    HostMax:   192.168.1.230
    Broadcast: 192.168.1.231
    Hosts/Net: 6                     Class C, Private Internet

    30.
    Network:   192.168.1.232/29
    HostMin:   192.168.1.233
    HostMax:   192.168.1.238
    Broadcast: 192.168.1.239
    Hosts/Net: 6                     Class C, Private Internet

    31.
    Network:   192.168.1.240/29
    HostMin:   192.168.1.241
    HostMax:   192.168.1.246
    Broadcast: 192.168.1.247
    Hosts/Net: 6                     Class C, Private Internet

    32.
    Network:   192.168.1.248/29
    HostMin:   192.168.1.249
    HostMax:   192.168.1.254
    Broadcast: 192.168.1.255
    Hosts/Net: 6                     Class C, Private Internet


    Subnets:   32
    Hosts:     192
Примеры /29 подсетей внутри сети 10.10.10.0/24

     1.
    Network:   10.10.10.0/29
    HostMin:   10.10.10.1
    HostMax:   10.10.10.6
    Broadcast: 10.10.10.7
    Hosts/Net: 6                     Class A, Private Internet

    2.
    Network:   10.10.10.8/29
    HostMin:   10.10.10.9
    HostMax:   10.10.10.14
    Broadcast: 10.10.10.15
    Hosts/Net: 6                     Class A, Private Internet

    3.
    Network:   10.10.10.16/29
    HostMin:   10.10.10.17
    HostMax:   10.10.10.22
    Broadcast: 10.10.10.23
    Hosts/Net: 6                     Class A, Private Internet
#### 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.
#### Решение:
Частные IP адреса можно взять из подсети 100.64.0.0 — 100.127.255.255 (маска подсети: 255.192.0.0 или /10) Carrier-Grade NAT.  

    vagrant@vagrant:~$ ipcalc 100.64.0.0 -s 50
    Address:   100.64.0.0           01100100.01000000.00000000. 00000000
    Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
    Wildcard:  0.0.0.255            00000000.00000000.00000000. 11111111
    =>
    Network:   100.64.0.0/24        01100100.01000000.00000000. 00000000
    HostMin:   100.64.0.1           01100100.01000000.00000000. 00000001
    HostMax:   100.64.0.254         01100100.01000000.00000000. 11111110
    Broadcast: 100.64.0.255         01100100.01000000.00000000. 11111111
    Hosts/Net: 254                   Class A

    1. Requested size: 50 hosts
    Netmask:   255.255.255.192 = 26 11111111.11111111.11111111.11 000000
    Network:   100.64.0.0/26        01100100.01000000.00000000.00 000000
    HostMin:   100.64.0.1           01100100.01000000.00000000.00 000001
    HostMax:   100.64.0.62          01100100.01000000.00000000.00 111110
    Broadcast: 100.64.0.63          01100100.01000000.00000000.00 111111
    Hosts/Net: 62                    Class A
    
    Needed size:  64 addresses.
    Used network: 100.64.0.0/26
#### 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
#### Решение:
Проверить ARP таблицу в Linux можно командой `ip neigh`.  

    vagrant@vagrant:~$ ip neigh
    10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 DELAY
    10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
В Windows ARP таблицу можно посмотреть командой `arp -a`.  
Очистить ARP кэш полностью в Linux можно командой `sudo ip neigh flush all`.  
Очистить ARP кэш полностью в Windows можно командой `netsh interface ip delete arpcache`.  
Удалить из ARP таблицы только один нужный IP в Linux можно командой ``