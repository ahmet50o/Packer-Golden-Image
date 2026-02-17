packer {
  required_version = ">= 1.9.0"

  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "qemu" "ubuntu-vm" {
  iso_url      = var.image_path
  iso_checksum = "sha256:${filesha256(var.image_path)}"
  disk_image   = true

  vm_name      = var.vm_name
  cpus         = var.cpus
  memory       = var.memory
  disk_size    = var.disk_size
  accelerator  = "kvm"
  format       = "qcow"
  output_directory = "output"

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "5m"


  cd_content = {
    "meta-data" = ""
    "user-data" = file("cloud-init/user-data.yml")
  }
  cd_label = "cidata"
}

build {
  sources = ["source.qemu.ubuntu-vm"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
  }
}
