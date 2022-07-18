resource "yandex_compute_instance" "gitlab-server" {
  name                      = "gitlab-server"
  zone                      = "ru-central1-b"
  hostname                  = "gitlab-server"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
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