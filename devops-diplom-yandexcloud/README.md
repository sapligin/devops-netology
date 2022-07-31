# Дипломный практикум Yandex Cloud
## 1. Регистрация доменного имени
Зарегистрировано доменное имя `sapligin.ru`
## 2. Создание инфраструктуры
В YC создан сервисный аккаунт `my-robot` с правами `editor`

Создан S3 bucket в аккаунте YC
![](IMG/1.PNG)

Пишем конфигурацию `terraform` с подсетями:
<details>
<summary>main.tf</summary>

```terraform
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }


  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tfbucket"
    region     = "ru-central1-a"
    key        = "tfbucket/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "../key.json"
  cloud_id  = "b1gkps1kvm3lbn7tuqda"
  folder_id = "b1g17mdarsc1bia6qhjt"
  zone      = "ru-central1-a"
}
```

</details>

<details>
<summary>network.tf</summary>

```terraform
resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "local-subnet" {
  name           = "local-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}
```

</details>

Инициализируем `terraform`
<details>
<summary>terraform init</summary>

```commandline
pligin@ubuntu:~$ terraform init --backend-config="access_key=XXXXXXXXX-XxxXXX-xXX_xXxX" --backend-config="secret_key=XXX_XXXxxXXxxxxXXxXxxXxXXxxXXxXxXxXXx-x"

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```
</details>

<details>
<summary>Создаем `workspace` `stage`</summary>

```commandline
pligin@ubuntu:~/Desktop/devops-diplom-yandexcloud/terraform$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
pligin@ubuntu:~/Desktop/devops-diplom-yandexcloud/terraform$ terraform workspace list 
  default
* stage

```
</details>

В результате команды `terraform plan` и `terraform apply` отрабатывают без ошибок.
<details>
<summary>terraform plan</summary>

```commandline
pligin@ubuntu:~/Desktop/devops-diplom-yandexcloud/terraform$ terraform plan 

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_vpc_network.network will be created
  + resource "yandex_vpc_network" "network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.local-subnet will be created
  + resource "yandex_vpc_subnet" "local-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "local-subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.private-subnet will be created
  + resource "yandex_vpc_subnet" "private-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "private-subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.

```
</details>

<details>
<summary>terraform apply</summary>

```commandline
pligin@ubuntu:~/Desktop/devops-diplom-yandexcloud/terraform$ terraform apply 

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_vpc_network.network will be created
  + resource "yandex_vpc_network" "network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.local-subnet will be created
  + resource "yandex_vpc_subnet" "local-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "local-subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.private-subnet will be created
  + resource "yandex_vpc_subnet" "private-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "private-subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions in workspace "stage"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.network: Creating...
yandex_vpc_network.network: Creation complete after 1s [id=enp7vdqdg0rr5ogq1qdm]
yandex_vpc_subnet.private-subnet: Creating...
yandex_vpc_subnet.local-subnet: Creating...
yandex_vpc_subnet.local-subnet: Creation complete after 1s [id=e2ltokvn53eck93mara9]
yandex_vpc_subnet.private-subnet: Creation complete after 2s [id=e9bdki9s6ujhht8olife]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```
</details>

В аккаунте YC создаются подсети:
![](IMG/subnets.PNG)

В S3 bucket пишется состояние конфигурации `terraform`
![](IMG/tfstate.PNG)

Команда `terraform destroy` уничтожает инфраструктуру:
<details>
<summary>terraform destroy</summary>

```commandline
pligin@ubuntu:~/Desktop/devops-diplom-yandexcloud/terraform$ terraform destroy 
yandex_vpc_network.network: Refreshing state... [id=enp7vdqdg0rr5ogq1qdm]
yandex_vpc_subnet.private-subnet: Refreshing state... [id=e9bdki9s6ujhht8olife]
yandex_vpc_subnet.local-subnet: Refreshing state... [id=e2ltokvn53eck93mara9]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # yandex_vpc_network.network will be destroyed
  - resource "yandex_vpc_network" "network" {
      - created_at = "2022-07-16T07:03:47Z" -> null
      - folder_id  = "b1g17mdarsc1bia6qhjt" -> null
      - id         = "enp7vdqdg0rr5ogq1qdm" -> null
      - labels     = {} -> null
      - name       = "network" -> null
      - subnet_ids = [
          - "e2ltokvn53eck93mara9",
          - "e9bdki9s6ujhht8olife",
        ] -> null
    }

  # yandex_vpc_subnet.local-subnet will be destroyed
  - resource "yandex_vpc_subnet" "local-subnet" {
      - created_at     = "2022-07-16T07:03:48Z" -> null
      - folder_id      = "b1g17mdarsc1bia6qhjt" -> null
      - id             = "e2ltokvn53eck93mara9" -> null
      - labels         = {} -> null
      - name           = "local-subnet" -> null
      - network_id     = "enp7vdqdg0rr5ogq1qdm" -> null
      - v4_cidr_blocks = [
          - "192.168.20.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-b" -> null
    }

  # yandex_vpc_subnet.private-subnet will be destroyed
  - resource "yandex_vpc_subnet" "private-subnet" {
      - created_at     = "2022-07-16T07:03:49Z" -> null
      - folder_id      = "b1g17mdarsc1bia6qhjt" -> null
      - id             = "e9bdki9s6ujhht8olife" -> null
      - labels         = {} -> null
      - name           = "private-subnet" -> null
      - network_id     = "enp7vdqdg0rr5ogq1qdm" -> null
      - v4_cidr_blocks = [
          - "192.168.10.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-a" -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources in workspace "stage"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

yandex_vpc_subnet.private-subnet: Destroying... [id=e9bdki9s6ujhht8olife]
yandex_vpc_subnet.local-subnet: Destroying... [id=e2ltokvn53eck93mara9]
yandex_vpc_subnet.private-subnet: Destruction complete after 2s
yandex_vpc_subnet.local-subnet: Destruction complete after 4s
yandex_vpc_network.network: Destroying... [id=enp7vdqdg0rr5ogq1qdm]
yandex_vpc_network.network: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.

```
</details>

## 3. Установка Nginx и LetsEncrypt
Написана роль для установки Nginx и LetsEncrypt.

В доменной зоне настроены все A-записи на внешний адрес сервера c Nginx (51.250.12.153)

![](IMG/dns.PNG)

В браузере можно открыть любой URL и увидеть ответ сервера (502 Bad Gateway). Также certbot сгенерировал сертификат:

![](IMG/site1.PNG)
