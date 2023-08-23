## VPC 설정 시작
resource "ncloud_vpc" "main" {
  ipv4_cidr_block = "10.1.0.0/16"
  name = "lion-tf"
}
## VPC 설정 끝

## 서브넷 설정 시작
# backend server subnet
resource "ncloud_subnet" "main" {
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC" # PUBLIC(Public) | PRIVATE(Private)
  usage_type     = "GEN" # GEN(General) | LOADB(For load balancer)
  name = "lion-tf-sub-main"
}

# load balancer subnet
resource "ncloud_subnet" "be-lb" {
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 2) # 맨뒤에 숫자 변경해서 네트워크 분리
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PRIVATE" # PUBLIC(Public) | PRIVATE(Private)
  usage_type     = "LOADB" # GEN(General) | LOADB(For load balancer) 로드 밸런서는 꼭 LOADB 로 설정
  name = "be-lb-subnet"
}
## 서브넷 설정 끝


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