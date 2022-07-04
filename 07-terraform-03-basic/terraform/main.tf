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
    # access_key необходмо заменить на свои
    access_key = "xxxxxxxxx-xxxxxx-xxxxxxxx"
    # secret_key необходмо заменить на свои
    secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = "b1gkps1kvm3lbn7tuqda"
  folder_id = "b1g17mdarsc1bia6qhjt"
  zone      = "ru-central1-a"
}
