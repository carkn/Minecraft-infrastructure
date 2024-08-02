# OS
data "sakuracloud_archive" "minecraft" {
  os_type = var.minecraft.os_type
}

# read local ssh pubkey
data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_path
}

# note ufw
resource "sakuracloud_note" "ubuntu_ufw" {
  name    = "Ubuntu UFW"
  class   = "shell"
  content = <<EOF
#!/bin/bash

# UFWの設定
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 25565/tcp
sudo ufw allow from 127.0.0.1 to any port 25575 proto tcp
sudo ufw allow from ${var.ssh_allow_ipaddr} to any port 22 proto tcp
yes | sudo ufw enable
EOF
}

# disk
resource "sakuracloud_disk" "minecraft_disk" {
  name              = "minecraft_disk"
  plan              = var.minecraft["plan"]
  size              = var.minecraft["size"]
  connector         = "virtio"
  source_archive_id = data.sakuracloud_archive.minecraft.id

  timeouts {
    create = "10m"
  }
}

# server
resource "sakuracloud_server" "minecraft_server" {
  name   = "minecraft_server"
  disks  = [sakuracloud_disk.minecraft_disk.id]
  core   = var.minecraft["core"]
  memory = var.minecraft["memory"]
  tags   = ["minecraft"]

  # network interface
  network_interface {
    upstream = "shared"
  }

  # disk_edit_parameter
  disk_edit_parameter {
    hostname = "minecraft"
    password = var.minecraft["password"]
    ssh_keys = [data.local_file.ssh_public_key.content]
    note {
      id = sakuracloud_note.ubuntu_ufw.id
    }
    disable_pw_auth = true
  }
}

# copy server global ipaddr
resource "local_file" "server_ip" {
  content  = sakuracloud_server.minecraft_server.ip_address
  filename = "${path.module}/minecraft_server.ini"
}
