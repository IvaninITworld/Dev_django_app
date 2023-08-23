variable "password" {
  type = string
}
variable "NCP_ACCESS_KEY" {
  type = string
  sensitive = true
}
variable "NCP_SECRET_KEY" {
  type = string
  sensitive = true
}

variable "NCP_CONTAINER_REGISTRY" {
  type = string
}

variable "IMAGE_TAG" {
  type = string
}

variable "db" {
    type = string
    sensitive = true
}

variable "db_user" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_port" {
  type = string
  sensitive = true
}

variable "DJANGO_SETTINGS_MODULE" {
  type = string
  sensitive = true
}

variable "DJANGO_SECRET_KEY" {
  type = string
  sensitive = true
}

variable "CHECK_CEHCK" {
  type = string
  sensitive = true
}