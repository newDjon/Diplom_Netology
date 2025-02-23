terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token = var.token
  folder_id = var.folder_id
  cloud_id = var.cloud_id
  zone = var.zone
}

