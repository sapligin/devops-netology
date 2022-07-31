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
      image_id = "fd84mnpg35f7s7b0f5lg" // nat-instance-ubuntu-1804-lts
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public-subnet.id}"
    nat        = true
    nat_ip_address = "51.250.12.153"
    ip_address = "192.168.10.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}