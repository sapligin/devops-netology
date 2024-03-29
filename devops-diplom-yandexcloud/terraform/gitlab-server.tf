resource "yandex_compute_instance" "gitlab-server" {
  name                      = "gitlab-server"
  zone                      = "ru-central1-b"
  hostname                  = "gitlab.sapligin.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    core_fraction = 20
    memory = 8
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8qs44945ddtla09hnr"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.local-subnet.id}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}