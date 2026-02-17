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
  iso_url      = "home/user1/meine_imgs/ubuntu_cloud.img"
  iso_checksum = "none"
  disk_image   = true
  vm_name      = "golden-ubuntu.qcow2"
  cpus         = 2
  memory       = 1024
  disk_size    = 10000

  
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
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
