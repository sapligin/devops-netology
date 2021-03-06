resource "yandex_compute_instance" "nginx" {
  name                      = "nginx"
  zone                      = "ru-central1-a"
  hostname                  = "nginx"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8qs44945ddtla09hnr"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public-subnet.id}"
    nat        = true
    ip_address = "192.168.10.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}