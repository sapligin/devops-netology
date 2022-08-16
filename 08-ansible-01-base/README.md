# Домашнее задание к занятию "08.01 Введение в Ansible"
## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2.	Создайте свой собственный публичный репозиторий на github с произвольным именем.
3.	Скачайте playbook из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Решение:
Установлена версия `ansible 2.13.1`
```commandline
pligin@server-demo:~$ ansible --version
ansible [core 2.13.1]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/pligin/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/pligin/.local/lib/python3.10/site-packages/ansible
  ansible collection location = /home/pligin/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/pligin/.local/bin/ansible
  python version = 3.10.4 (main, Jun 29 2022, 12:14:53) [GCC 11.2.0]
  jinja version = 3.0.3
  libyaml = True
```
Создан публичный репозиторий, скачан playbook и перенесен в свой репозиторий

## Основная часть
1.	Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2.	Найдите файл с переменными (`group_vars`) в котором задаётся найденное в первом пункте значение и поменяйте его на `all default fact`.
3.	Воспользуйтесь подготовленным (используется docker) или создайте собственное окружение для проведения дальнейших испытаний.
4.	Проведите запуск playbook на окружении из prod.yml. Зафиксируйте полученные значения some_fact для каждого из managed host.
5.	Добавьте факты в group_vars каждой из групп хостов так, чтобы для some_fact получились следующие значения: для deb - 'deb default fact', для el - 'el default fact'.
6.	Повторите запуск playbook на окружении prod.yml. Убедитесь, что выдаются корректные значения для всех хостов.
7.	При помощи ansible-vault зашифруйте факты в group_vars/deb и group_vars/el с паролем netology.
8.	Запустите playbook на окружении prod.yml. При запуске ansible должен запросить у вас пароль. Убедитесь в работоспособности.
9.	Посмотрите при помощи ansible-doc список плагинов для подключения. Выберите подходящий для работы на control node.
10.	В prod.yml добавьте новую группу хостов с именем local, в ней разместите localhost с необходимым типом подключения.
11.	Запустите playbook на окружении prod.yml. При запуске ansible должен запросить у вас пароль. Убедитесь что факты some_fact для каждого из хостов определены из верных group_vars.
12.	Заполните README.md ответами на вопросы. Сделайте git push в ветку master. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым playbook и заполненным README.md.

## Решение:
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

Запущен playbook из окружение `test`. Факт `some_fact` имеет значение `12`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
2. Найдите файл с переменными (`group_vars`) в котором задаётся найденное в первом пункте значение и поменяйте его на `all default fact`.

Поменял значение переменной на `all default fact`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
3. Воспользуйтесь подготовленным (используется docker) или создайте собственное окружение для проведения дальнейших испытаний.

В docker запущены контейнер с `centos7` и контейнер с `ubuntu`
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

Значение `some_fact` для `centos7` - `el`

Значение `some_fact` для `ubuntu` - `deb`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - `deb default fact`, для `el` - `el default fact`.

Добавляем факты для `deb`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ cat group_vars/deb/examp.yml
---
  some_fact: "deb default fact"
```
Добавляем факты для `el`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ cat group_vars/el/examp.yml
---
  some_fact: "el default fact"p
```
6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

Выдаются корректные значения для всех хостов
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
7.	При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с `паролем netology`.

Файл `group_vars/deb/examp.yml` зашифрован с паролем `netology`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
```
Файл `group_vars/el/examp.yml` зашифрован с паролем `netology`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-vault encrypt group_vars/el/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
```
8. Запустите playbook на окружении `prod.yml`. При запуске ansible должен запросить у вас пароль. Убедитесь в работоспособности.

Для выполнения playbook надо передать флаг `--ask-vault-pass`
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
9.	Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

С помощью команды `ansible-doc -t connection -l` смотрим список плагинов для подключения.
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-doc -t connection -l
ansible.netcommon.httpapi      Use httpapi to run command on network appliances
ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ssh connection
ansible.netcommon.napalm       Provides persistent connection using NAPALM
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol
ansible.netcommon.network_cli  Use network_cli to run command on network appliances
ansible.netcommon.persistent   Use a persistent unix socket for connection
community.aws.aws_ssm          execute via AWS Systems Manager
community.docker.docker        Run tasks in docker containers
community.docker.docker_api    Run tasks in docker containers
community.docker.nsenter       execute on host running controller container
community.general.chroot       Interact with local chroot
community.general.funcd        Use funcd to connect to target
community.general.iocage       Run tasks in iocage jails
community.general.jail         Run tasks in jails
community.general.lxc          Run tasks in lxc containers via lxc python library
community.general.lxd          Run tasks in lxc containers via lxc CLI
community.general.qubes        Interact with an existing QubesOS AppVM
community.general.saltstack    Allow ansible to piggyback on salt minions
community.general.zone         Run tasks in a zone instance
community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt
community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines
community.okd.oc               Execute tasks in pods running on OpenShift
community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools
community.zabbix.httpapi       Use httpapi to run command on network appliances
containers.podman.buildah      Interact with an existing buildah container
containers.podman.podman       Interact with an existing podman container
kubernetes.core.kubectl        Execute tasks in pods running on Kubernetes
local                          execute on controller
paramiko_ssh                   Run tasks via python ssh (paramiko)
psrp                           Run tasks over Microsoft PowerShell Remoting Protocol
ssh                            connect via SSH client binary
winrm                          Run tasks over Microsoft's WinRM
```
Для `control node` подойдет плагин `local`

10.	В `prod.yml` добавьте новую группу хостов с именем `local`, в ней разместите `localhost` с необходимым типом подключения.

```
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker

  local:
    hosts:
      localhost:
        ansible_connection: local
```
11.	Запустите playbook на окружении `prod.yml`. При запуске ansible должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

Факты для каждого хоста определяются правильно.
```commandline
pligin@server-demo:~/08-ansible-01-base/playbook$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

10. Заполните README.md ответами на вопросы. Сделайте git push в ветку master. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым playbook и заполненным README.md.

[Ссылка на репозиторий с изменённым playbook и заполненным README.md](https://github.com/sapligin/08-ansible-01-base/blob/main/README.md)
