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
  region      = "KR"
  site        = "PUBLIC"
  support_vpc = true
  access_key = var.NCP_ACCESS_KEY
  secret_key = var.NCP_SECRET_KEY
}

module "servers" {
    source = "../modules/server"

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
}

# // Create a new server instance
# resource "ncloud_login_key" "loginkey" {
#   key_name = "test-key"
# }

# ## network interface 생성 후 acg 추가 설정 시작
# # web
# resource "ncloud_network_interface" "web" {
#     name                  = "be-nic"
#     description           = "for example"
#     subnet_no             = ncloud_subnet.main.id
#     # private_ip            = "10.1.0.6" # 직접 지정해서 사용해도 되나, 같은 서브넷 안에서 만들어 질 수 없기 때문에 다 다르게 설정해야하는 귀찮음 때문에 삭제하고 자동으로 넣어주게 끔 한다.
#     access_control_groups = [
#         ncloud_vpc.main.default_access_control_group_no,
#         ncloud_access_control_group.web.id,
#     ]
# }
# # db
# resource "ncloud_network_interface" "db" {
#     name                  = "db-nic"
#     description           = "for example"
#     subnet_no             = ncloud_subnet.main.id
#     access_control_groups = [
#         ncloud_vpc.main.default_access_control_group_no,
#         ncloud_access_control_group.db.id,
#     ]
# }
# ## network interface 생성 후 acg 추가 설정 끝

# ## Main backend server 설정 시작
# resource "ncloud_server" "server" {
#   subnet_no                 = ncloud_subnet.main.id
#   name                      = "be-staging"
#   server_image_product_code =  "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
#   server_product_code       = data.ncloud_server_products.products.server_products[0].product_code # 서버스펙 설정
#   login_key_name            = ncloud_login_key.loginkey.key_name
#   init_script_no            = ncloud_init_script.be.init_script_no

#   network_interface {
#     network_interface_no = ncloud_network_interface.web.id
#     order = 0
#     }
# #   access_control_group_configuration_no_list = [ ncloud_access_control_group.web.id ] # 자동으로 ACG 를 설정하는 부분이지만 NCP 에서는 아직 지원하지 않는 듯
# }
# # 공인 아이피 설정 및 부여
# resource "ncloud_public_ip" "main" { # 빈 깡통으로 넣어주기만 해도 공인 IP는 생성
#     server_instance_no = ncloud_server.server.instance_no
#     description = "public IP for backend server"
# }
# ## Main backend server 설정 끝

# ## DB 서버 instance 생성 시작
# resource "ncloud_server" "db" {
#   subnet_no                 = ncloud_subnet.main.id
#   name                      = "db-staging"
#   server_image_product_code =  "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
#   server_product_code       = data.ncloud_server_products.products.server_products[0].product_code # 서버스펙 설정
#   login_key_name            = ncloud_login_key.loginkey.key_name
#   init_script_no            = ncloud_init_script.db.init_script_no
#   network_interface {
#     network_interface_no = ncloud_network_interface.db.id
#     order = 0
#     }
# }
# # 공인 아이피 설정 및 부여
# resource "ncloud_public_ip" "db" { # db 용
#     server_instance_no = ncloud_server.db.instance_no
#     description = "public IP for db server"
# }
# ## DB 서버 instance 생성 끝