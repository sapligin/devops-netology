output "internal_ip_address_nginx" {
  value = "${yandex_compute_instance.nginx.network_interface.0.ip_address}"
}

output "external_ip_address_nginx" {
  value = "${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"
}

output "internal_ip_address_mysql-master" {
  value = "${yandex_compute_instance.mysql-master.network_interface.0.ip_address}"
}

output "internal_ip_address_mysql-slave" {
  value = "${yandex_compute_instance.mysql-slave.network_interface.0.ip_address}"
}

output "internal_ip_address_wordpress" {
  value = "${yandex_compute_instance.wordpress.network_interface.0.ip_address}"
}

output "internal_ip_address_gitlab-server" {
  value = "${yandex_compute_instance.gitlab-server.network_interface.0.ip_address}"
}

output "internal_ip_address_gitlab-runner" {
  value = "${yandex_compute_instance.gitlab-runner.network_interface.0.ip_address}"
}

output "internal_ip_address_monitoring" {
  value = "${yandex_compute_instance.monitoring.network_interface.0.ip_address}"
}