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

// Create a new server instance
resource "ncloud_login_key" "loginkey" {
  key_name = "test-key"
}

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
  init_script_no            = ncloud_init_script.be.init_script_no

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
## 서버스펙 데이터 삽입 끝

## init script 설정 시작
resource "ncloud_init_script" "be" {
  name    = "set-be-tf"
  content = templatefile("${path.module}/be_init_script.tftpl", {
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
    CHECK_CEHCK = var.CHECK_CEHCK
  })
} # Shell Script 로 가져다 쓰기: .tftpl

resource "ncloud_init_script" "db" {
  name    = "set-db-tf"
  content = templatefile("${path.module}/db_init_script.tftpl", {
    password = var.password
    db = var.db
    db_user = var.db_user
    db_password = var.db_password
    db_port = var.db_port
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
  init_script_no            = ncloud_init_script.db.init_script_no
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
## DB 서버 instance 생성 끝

## Load Balancer 생성 시작
# Load Balancer
resource "ncloud_lb" "lion-lb-tf" {
  name = "be-lb-staging"
  network_type = "PUBLIC"
  type = "NETWORK_PROXY"
  # 로드 밸런서는 구분지어진 하나의 서브넷을 받기 때문에 따로 설정해준다.
  subnet_no_list = [ ncloud_subnet.be-lb.id ]
}

# Target group
resource "ncloud_lb_target_group" "lion-lb-tf" {
  vpc_no   = ncloud_vpc.main.vpc_no
  protocol = "PROXY_TCP"
  target_type = "VSVR" # Target type 에서 VPC
  port        = 8000
  description = "for django be"
  health_check {
    protocol = "TCP" # PROXY_TCP 는 체크도 TCP 만
    http_method = "GET"
    port           = 8000
    url_path       = "/monitor/l7check"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

# 어떤 프로토콜을 리스닝할건지 정의
resource "ncloud_lb_listener" "lion-lb-tf" {
  load_balancer_no = ncloud_lb.lion-lb-tf.load_balancer_no
  protocol = "TCP"
  port = 80
  target_group_no = ncloud_lb_target_group.lion-lb-tf.target_group_no
}

# 타겟 그룹 설정으로 대상 서버 인스터스를 정할 수 있다
# Target group attachment
resource "ncloud_lb_target_group_attachment" "lion-lb-tg-tf" {
  target_group_no = ncloud_lb_target_group.lion-lb-tf.target_group_no
  target_no_list = [ncloud_server.server.instance_no]
}
## Load Balancer 생성 끝
