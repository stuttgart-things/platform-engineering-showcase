packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.9"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.0"
    }
  }
}


source "qemu" "ubuntu_plucky" {
  # ISO
  iso_url      = "https://releases.ubuntu.com/25.04/ubuntu-25.04-live-server-amd64.iso"
  iso_checksum = "sha256:8b44046211118639c673335a80359f4b3f0d9e52c33fe61c59072b1b61bdecc5"

  # VM hardware
  accelerator = "kvm"
  cpus        = 2
  memory      = 2048
  disk_size   = "20G"

  # Output
  output_directory = "output/ubuntu-plucky"
  vm_name          = "ubuntu-plucky"

  # Boot
  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz autoinstall ---<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]

  # SSH (must match installer user)
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "45m"

  # Shutdown
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"

  # QEMU options
  headless = false
}

build {
  sources = ["source.qemu.ubuntu_plucky"]

  provisioner "shell" {
    inline = [
      "echo 'Packer build completed on Ubuntu Plucky'",
      "uname -a"
    ]
  }
}