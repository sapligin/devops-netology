resource "time_sleep" "wait_for_inventory" {
  create_duration = "90s"

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "ansible_site" {
  provisioner "local-exec" {
    command = "cd ../ansible && ANSIBLE_FORCE_COLOR=1 ansible-playbook -i inventory all.yml -vvvv"
  }

  depends_on = [
    time_sleep.wait_for_inventory
  ]
}