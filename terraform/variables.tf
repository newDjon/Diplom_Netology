variable "token" {
  type = string
  sensitive = true
}

variable "folder_id" {
  description = "folder_id"
  type        = string
}

variable "cloud_id" {
  description = "cloud_id"
  type = string
  
}

variable "zone" {
    default = "ru-central1-a"
}

variable "zone2" {
    default = "ru-central1-b"
}

variable "service_id" {
  description = "service_id"
  type = string
}