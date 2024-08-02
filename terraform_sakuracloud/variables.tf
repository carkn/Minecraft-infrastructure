# SakuraCloud
variable "sakuracloud_token" {
  sensitive = true
  description = "さくらのクラウド APIキートークン"
}

variable "sakuracloud_secret" {
  sensitive = true
  description = "さくらのクラウド APIキーシークレット"
}

variable "sakura_zone" {
  sensitive = true
  description = "さくらのクラウド ゾーン"
}

# ssh key
variable "ssh_public_key_path" {
  sensitive = true
  description = "SSH公開鍵のパスの指定"
  type        = string
}

# ssh allow ipaddr
variable "ssh_allow_ipaddr" {
  sensitive = true
  description = "端末のグローバルIPアドレスを指定"
  type        = string
}

# config minecraft
variable "minecraft" {
  type        = map(string)
  default     = {
    os_type   = "ubuntu2204"
    core      = "2"
    memory    = "4"
    plan      = "ssd"
    size      = "40"
    password  = "password"
  }
}