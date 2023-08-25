terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

// Configure the ncloud provider
provider "ncloud" {
  access_key  = var.NCP_ACCESS_KEY
  secret_key  = var.NCP_SECRET_KEY
  region      = var.region
  site        = var.site
  support_vpc = var.support_vpc
}

locals {
  env = "staging"
}

module "network" {
  source = "../modules/network"

  env = local.env

  region = var.region
  site = var.site
  support_vpc = var.support_vpc

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
}

module "servers" {
  source = "../modules/server"

  # going to variabels.tf
  env = local.env
  
  region = var.region
  site = var.site
  support_vpc = var.support_vpc

  username = var.username
  password = var.password

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  NCP_CONTAINER_REGISTRY = var.NCP_CONTAINER_REGISTRY
  IMAGE_TAG = var.IMAGE_TAG

  db = var.db
  db_user = var.db_user
  db_password = var.db_password
  db_port = var.db_port

  DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
  DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY

  vpc_id = module.network.vpc_id
  subnet_be_server = module.network.subnet_be_server

}

module "be" {
  source = "../modules/server"

  # env = local.env
  
  # region = var.region
  # site = var.site
  # support_vpc = var.support_vpc

  # username = var.username
  # password = var.password

  # NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  # NCP_SECRET_KEY = var.NCP_SECRET_KEY
  # NCP_CONTAINER_REGISTRY = var.NCP_CONTAINER_REGISTRY
  # IMAGE_TAG = var.IMAGE_TAG

  # db = var.db
  # db_user = var.db_user
  # db_password = var.db_password
  # db_port = var.db_port

  # DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
  # DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY

  # vpc_id = module.network.vpc_id
}

module "db" {
  source = "../modules/server"

  # env = local.env
  
  # region = var.region
  # site = var.site
  # support_vpc = var.support_vpc

  # username = var.username
  # password = var.password

  # NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  # NCP_SECRET_KEY = var.NCP_SECRET_KEY
  # NCP_CONTAINER_REGISTRY = var.NCP_CONTAINER_REGISTRY
  # IMAGE_TAG = var.IMAGE_TAG

  # db = var.db
  # db_user = var.db_user
  # db_password = var.db_password
  # db_port = var.db_port

  # DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
  # DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY

  # vpc_id = module.network.vpc_id
}


module "loadbalancer" {
  source = "../modules/loadbalancer"

  env = local.env

  region = var.region
  site = var.site
  support_vpc = var.support_vpc

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY

  vpc_id = module.network.vpc_id
  be_server = module.servers.be_server
  subnet_be_loadbalancer = module.network.subnet_be_loadbalancer
}