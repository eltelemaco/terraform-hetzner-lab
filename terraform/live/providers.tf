terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.56.0"
    }
  }
  required_version = ">= 1.5"
}

provider "hcloud" {
  token = var.hcloud_token
}