resource "time_sleep" "waiting_for_provisioning" {
  create_duration = "90s"

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "ansible_site" {
  provisioner "local-exec" {
    command = "cd ../ansible && ANSIBLE_FORCE_COLOR=1 ansible-playbook -i inventory/inventory.yml all.yml -vvvv"
  }

  depends_on = [
    time_sleep.waiting_for_provisioning
  ]
}