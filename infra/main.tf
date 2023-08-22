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
}

variable "password" {
  type = string
}

// Create a new server instance
resource "ncloud_login_key" "loginkey" {
  key_name = "test-key"
}

## VPC 설정 시작
resource "ncloud_vpc" "main" {
  ipv4_cidr_block = "10.1.0.0/16"
  name = "lion-tf"
}
## VPC 설정 끝

## ACG 설정 시작
# db
resource "ncloud_access_control_group" "db" {
  name        = "lion-db"
  description = "postgres db ACG"
  vpc_no      = ncloud_vpc.main.vpc_no
}
# Inbound rule
resource "ncloud_access_control_group_rule" "db-acg-rule" {
  access_control_group_no = ncloud_access_control_group.db.id

  inbound { # DB 는 subnet 과 같은 ip 블럭으로 private 하게 해야하지만 staging 이니 일단 ok
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "5432"
    description = "accept 5432 port for postgres"
  }
}

data "ncloud_access_control_group" "default" {
    id = "124479" # lion-tf-default-acg
}

# web
resource "ncloud_access_control_group" "web" {
  name        = "lion-web"
  description = "web ACG"
  vpc_no      = ncloud_vpc.main.vpc_no
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
## ACG 설정 끝

## 서브넷 설정 시작
resource "ncloud_subnet" "main" {
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
  name = "lion-tf-sub-main"
}

resource "ncloud_subnet" "be-lb" {
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 2) # 맨뒤에 숫자 변경
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PRIVATE" // PUBLIC(Public) | PRIVATE(Private)
  usage_type     = "LOADB" // GEN(General) | LOADB(For load balancer) 로드 밸런서는 꼭 LOADB 로 설정
  name = "be-lb-subnet"
}
## 서브넷 설정 끝

## network interface 생성 후 acg 추가 설정 시작
# web
resource "ncloud_network_interface" "web" {
    name                  = "be-nic"
    description           = "for example"
    subnet_no             = ncloud_subnet.main.id
    # private_ip            = "10.1.0.6" # 직접 지정해서 사용해도 되나, 같은 서브넷 안에서 만들어 질 수 없기 때문에 다 다르게 설정해야하는 귀찮음 때문에 삭제하고 자동으로 넣어주게 끔 한다.
    access_control_groups = [
        ncloud_vpc.main.default_access_control_group_no,
        ncloud_access_control_group.web.id,
    ]
}
# db
resource "ncloud_network_interface" "db" {
    name                  = "db-nic"
    description           = "for example"
    subnet_no             = ncloud_subnet.main.id
    access_control_groups = [
        ncloud_vpc.main.default_access_control_group_no,
        ncloud_access_control_group.db.id,
    ]
}
## network interface 생성 후 acg 추가 설정 끝

## Main backend server 설정 시작
resource "ncloud_server" "server" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "be-staging"
  server_image_product_code =  "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.products.server_products[0].product_code # 서버스펙 설정
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init.init_script_no

  network_interface {
    network_interface_no = ncloud_network_interface.web.id
    order = 0
    }
#   access_control_group_configuration_no_list = [ ncloud_access_control_group.web.id ] # 자동으로 ACG 를 설정하는 부분이지만 NCP 에서는 아직 지원하지 않는 듯
}

# 공인 아이피 설정 및 부여
resource "ncloud_public_ip" "main" { # 빈 깡통으로 넣어주기만 해도 공인 IP는 생성
    server_instance_no = ncloud_server.server.instance_no
    description = "public IP for backend server"
}

# 공인 IP 를 생성하면서 가져오기
output "backend_public_ip" {
  value = ncloud_public_ip.main.public_ip
}
## Main backend server 설정 끝

## 서버스펙 데이터 삽입 시작
data "ncloud_server_products" "products" {
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"

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

output "products" {
  value = {
    for product in data.ncloud_server_products.products.server_products:
    product.id => product.product_name
  }
}
## 서버스펙 데이터 삽입 끝


## init script 설정 시작
resource "ncloud_init_script" "init" {
  name    = "set-docker-tf"
  content = templatefile("${path.module}/main_init_script.tftpl", {
    password = var.password
  })
} # Shell Script 로 가져다 쓰기: .tftpl
## init script 설정 시작

## DB 서버 instance 생성 시작
resource "ncloud_server" "db" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "db-staging"
  server_image_product_code =  "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.products.server_products[0].product_code # 서버스펙 설정
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.db.id
    order = 0
    }
}

# 공인 아이피 설정 및 부여
resource "ncloud_public_ip" "db" { # db 용
    server_instance_no = ncloud_server.db.instance_no
    description = "public IP for db server"
}

# 공인 IP 를 생성하면서 가져오기
output "db_public_ip" {
  value = ncloud_public_ip.db.public_ip
}
## DB 서버 instance 생성 끝

## Load Balancer 생성 시작
# Load Balancer
resource "ncloud_lb" "lion-lb-tf" {
  name = "be-lb-staging"
  network_type = "PUBLIC"
  type = "NETWORK_PROXY"
  subnet_no_list = [ ncloud_subnet.be-lb.id ]
}

output "ncloud-lb-domain" {
  value = ncloud_lb.lion-lb-tf.domain
}

# Target group
resource "ncloud_lb_target_group" "lion-lb-tf" {
  vpc_no   = ncloud_vpc.main.vpc_no
  protocol = "PROXY_TCP"
  target_type = "VSVR" # Target type 에서 VPC
  port        = 8000
  description = "for django be"
  health_check {
    protocol = "TCP"
    http_method = "GET"
    port           = 8080
    url_path       = "/monitor/l7check"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

resource "ncloud_lb_listener" "lion-lb-tf" {
  load_balancer_no = ncloud_lb.lion-lb-tf.load_balancer_no
  protocol = "TCP"
  port = 80
  target_group_no = ncloud_lb_target_group.lion-lb-tf.target_group_no
}

# Target group attachment
resource "ncloud_lb_target_group_attachment" "lion-lb-tg-tf" {
  target_group_no = ncloud_lb_target_group.lion-lb-tf.target_group_no
  target_no_list = [ncloud_server.server.instance_no]
}

