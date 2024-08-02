terraform {
  # SakuraCloud
  required_providers {
    sakuracloud = {
      source = "sacloud/sakuracloud"

      version = "2.25.3"
    }
  }
}

provider "sakuracloud" {
  token  = var.sakuracloud_token
  secret = var.sakuracloud_secret
  zone   = var.sakura_zone
}