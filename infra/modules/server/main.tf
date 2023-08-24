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

##### server 

# SSH 로 서버에 접근할 때 쓰는 키 -> pem 키?
resource "ncloud_login_key" "loginkey" {
  key_name = "key-${var.env}"
}

## be backend server setup start
resource "ncloud_server" "be-server" {
  subnet_no                 = ncloud_subnet.be-server.id
  name                      = "be-server-${var.env}"
  server_image_product_code = data.ncloud_server_products.products.server_image_product_code
  server_product_code       = data.ncloud_server_products.products.product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no = ncloud_init_script.be.id

  network_interface {
    network_interface_no = ncloud_network_interface.web.id
    order = 0
  }
}
resource "ncloud_public_ip" "be" {
  server_instance_no = ncloud_server.be-server.id
  description = "public IP for backend server prod"
}
## be backend server setup end

## db server setup start
resource "ncloud_server" "db-server" {
  subnet_no                 = ncloud_subnet.be-server.id
  name                      = "db-server-${var.env}"
  server_image_product_code = data.ncloud_server_products.products.server_image_product_code
  server_product_code       = data.ncloud_server_products.products.product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no = ncloud_init_script.db.id

  network_interface {
    network_interface_no = ncloud_network_interface.db.id
    order = 0
  }
}
resource "ncloud_public_ip" "db" {
  server_instance_no = ncloud_server.db-server.id
  description = "public IP for db server ${var.env}"
}
## db server setup end


##### server end

##### server sepc
# https://github.com/NaverCloudPlatform/terraform-ncloud-docs/blob/main/docs/vpc_products/ubuntu-20.04.md

# server product setup start
data "ncloud_server_products" "products" {
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }

  filter {
    name   = "cpu_count"
    values = ["2"]
  }

  filter {
    name   = "memory_size"
    values = ["4GB"]
  }

  filter {
    name   = "base_block_storage_size"
    values = ["50GB"]
  }

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }

  output_file = "product.json"
}

# server product setup end

##### server sepc end

##### network

# ## VPC setup start 
# // cidr_block
# resource "ncloud_vpc" "main" {
#     name = "lion-${var.env}-tf"
#     ipv4_cidr_block = "10.10.0.0/16"
# }

# resource "ncloud_network_acl" "nacl" {
#     vpc_no = ncloud_vpc.main.id
# }

data "ncloud_vpc" "main" {
  id = var.vpc_id
}
# ## VPC setup end


## Subnet setup start 
// vpc_no, subnet: cidrsubnet, subnet_type, usage_type
resource "ncloud_subnet" "be-server" {
    vpc_no         = data.ncloud_vpc.main.vpc_no
    subnet         = cidrsubnet(data.ncloud_vpc.main.ipv4_cidr_block, 8, 3)
    zone           = "KR-2"
    network_acl_no = data.ncloud_vpc.main.default_network_acl_no
    subnet_type    = "PUBLIC"
    name           = "be-server-${var.env}"
    usage_type     = "GEN"
}
# load blanacer
resource "ncloud_subnet" "be-loadbalancer" {
    vpc_no         = data.ncloud_vpc.main.id
    subnet         = cidrsubnet(data.ncloud_vpc.main.ipv4_cidr_block, 8, 4)
    zone           = "KR-2"
    network_acl_no = data.ncloud_vpc.main.default_network_acl_no
    subnet_type    = "PRIVATE" // PUBLIC(Public) | PRIVATE(Private)
    // below fields is optional
    name           = "be-loadbalancer-${var.env}"
    usage_type     = "LOADB"    // GEN(General) | LOADB(For load balancer)
}
## Subnet setup end





## network interface setup for ACG start
// number of network interface, access_control_group, subnet_no
# web
resource "ncloud_network_interface" "web" {
    name                  = "be-nic-${var.env}"
    description           = "for Django web backend server"
    subnet_no             = ncloud_subnet.be-server.id
    # private_ip            = "10.1.0.6" # 직접 지정해서 사용해도 되나, 같은 서브넷 안에서 만들어 질 수 없기 때문에 다 다르게 설정해야하는 귀찮음 때문에 삭제하고 자동으로 넣어주게 끔 한다.
    access_control_groups = [
        data.ncloud_vpc.main.default_access_control_group_no,
        ncloud_access_control_group.web.id,
    ]
}
# db
resource "ncloud_network_interface" "db" {
    name                  = "db-nic-${var.env}"
    description           = "for DB server"
    subnet_no             = ncloud_subnet.be-server.id
    access_control_groups = [
        data.ncloud_vpc.main.default_access_control_group_no,
        ncloud_access_control_group.db.id,
    ]
}
## network interface setup for ACG end





## ACG: access control group setup start
// ncloud_access_control_group, ncloud_access_control_group_rule
# db
resource "ncloud_access_control_group" "db" {
  name        = "lion-db-${var.env}"
  description = "prod postgres db ACG"
  vpc_no      = data.ncloud_vpc.main.vpc_no
}
# Inbound rule
resource "ncloud_access_control_group_rule" "db-acg-rule" {
  access_control_group_no = ncloud_access_control_group.db.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "5432"
    description = "accept 5432 port for postgres"
  }
}

# data "ncloud_access_control_group" "default" {
#     # id = """
# }

# web
resource "ncloud_access_control_group" "web" {
  name        = "lion-web-${var.env}"
  description = "prod web ACG"
  vpc_no      = data.ncloud_vpc.main.vpc_no
}

# Inbound rule
resource "ncloud_access_control_group_rule" "web-acg-rule" {
  access_control_group_no = ncloud_access_control_group.web.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "8000"
    description = "accept 8000 port for Django"
  }
}
## ACG: access control group setup end


##### network end

##### initscript 

## init script setup start
# be_init
resource "ncloud_init_script" "be" {
  name    = "set-be-${var.env}-tf"
  content = templatefile("${path.module}/be_init_script.tftpl", {
    username = var.username
    password = var.password
    db = var.db
    db_user = var.db_user
    db_password = var.db_password
    db_port = var.db_port
    db_host = ncloud_public_ip.db.public_ip
    NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
    NCP_SECRET_KEY = var.NCP_SECRET_KEY
    NCP_CONTAINER_REGISTRY = var.NCP_CONTAINER_REGISTRY
    IMAGE_TAG = var.IMAGE_TAG
    DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY
    DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
  })
}

# db_init
resource "ncloud_init_script" "db" {
  name    = "set-db-${var.env}-tf"
  content = templatefile("${path.module}/db_init_script.tftpl", {
    username = var.username
    password = var.password
    db = var.db
    db_user = var.db_user
    db_password = var.db_password
    db_port = var.db_port
  })
}
## init script setup end

##### initscript end
