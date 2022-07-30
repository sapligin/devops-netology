resource "local_file" "inventory" {
  content  = <<-DOC
    ---
    nginx-group:
      hosts:
        nginx:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.nginx.network_interface.0.ip_address}

    mysql-group:
      hosts:
        mysql-master:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.mysql-master.network_interface.0.ip_address}
        mysql-slave:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.mysql-slave.network_interface.0.ip_address}

    wordpress-group:
      hosts:
        wordpress:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.wordpress.network_interface.0.ip_address}

    gitlab-group:
      hosts:
        gitlab-server:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.gitlab-server.network_interface.0.ip_address}
        gitlab-runner:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.gitlab-runner.network_interface.0.ip_address}

    monitoring-group:
      hosts:
        monitoring:
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${var.yandex_ubuntu_user}@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
          ansible_user: ${var.yandex_ubuntu_user}
          ansible_host: ${yandex_compute_instance.monitoring.network_interface.0.ip_address}

    DOC
  filename = "../ansible/inventory/inventory.yml"

  depends_on = [
    yandex_compute_instance.nginx,
    yandex_compute_instance.mysql-master,
    yandex_compute_instance.mysql-slave,
    yandex_compute_instance.wordpress,
    yandex_compute_instance.gitlab-server,
    yandex_compute_instance.gitlab-runner,
    yandex_compute_instance.monitoring
  ]
}