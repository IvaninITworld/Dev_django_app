# Cloud setup
variable "region" {
  type = string
}
variable "site" {
  type = string
}
variable "support_vpc" {
  type = bool
}

# instance setup
variable "name" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
variable "product_code" {
  type = string
}



# NCP setup
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

# DB setup
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
  default = "5432"
  sensitive = true
}

# Django setup
variable "DJANGO_SETTINGS_MODULE" {
  type = string
  sensitive = true
}
variable "DJANGO_SECRET_KEY" {
  type = string
  sensitive = true
}


# env
variable "env" {
  type = string  
}

# vpc
variable "vpc_id" {
  type = string
}

# acg_port_range
variable "acg_port_range" {
  type = string
}

# subnet
variable "subnet_be_server" {
  type = string
}


# init_script
variable "init_script_path" {
  type = string
}

variable "init_script_envs" {
  type = map(any)
}


# product code
variable "server_product_code" {
  type = string
}