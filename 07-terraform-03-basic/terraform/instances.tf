data "yandex_compute_image" "ubuntu" {
    family = "ubuntu-2004-lts"
}

locals {
  instance_count_map = {
    stage = 1
    prod  = 2
  }
  
  instance_for_each = {
    stage = toset(["srv"])
    prod  = toset([
        "srv1",
        "srv2",
        ])
  }
}

resource "yandex_compute_instance" "vm_count" {
  count = local.instance_count_map[terraform.workspace]
  name = "${terraform.workspace}-${count.index}"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qps171vp141hl7g9l"
      size = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm_for_each" {
  for_each = local.instance_for_each[terraform.workspace]
  name = "${terraform.workspace}-${each.key}"

  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qps171vp141hl7g9l"
      size = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

