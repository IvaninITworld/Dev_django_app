## VPC setup start 
// cidr_block
resource "ncloud_vpc" "prod-main" {
    name = "lion-prod-tf"
    ipv4_cidr_block = "10.10.0.0/16"
}

resource "ncloud_network_acl" "nacl" {
    vpc_no = ncloud_vpc.prod-main.id
}
## VPC setup end




## Subnet setup start 
// vpc_no, subnet: cidrsubnet, subnet_type, usage_type
resource "ncloud_subnet" "be-prod-server" {
    vpc_no         = ncloud_vpc.prod-main.vpc_no
    subnet         = cidrsubnet(ncloud_vpc.prod-main.ipv4_cidr_block, 8, 3)
    zone           = "KR-2"
    network_acl_no = ncloud_vpc.prod-main.default_network_acl_no
    subnet_type    = "PUBLIC"
    name           = "be-prod-server"
    usage_type     = "GEN"
}
# load blanacer
resource "ncloud_subnet" "be-prod-loadbalancer" {
    vpc_no         = ncloud_vpc.prod-main.id
    subnet         = cidrsubnet(ncloud_vpc.prod-main.ipv4_cidr_block, 8, 4)
    zone           = "KR-2"
    network_acl_no = ncloud_vpc.prod-main.default_network_acl_no
    subnet_type    = "PRIVATE" // PUBLIC(Public) | PRIVATE(Private)
    // below fields is optional
    name           = "be-prod-loadbalancer"
    usage_type     = "LOADB"    // GEN(General) | LOADB(For load balancer)
}
## Subnet setup end





## network interface setup for ACG start
// number of network interface, access_control_group, subnet_no
# web
resource "ncloud_network_interface" "web-prod" {
    name                  = "be-prod-nic"
    description           = "for prod Django web backend server"
    subnet_no             = ncloud_subnet.be-prod-server.id
    # private_ip            = "10.1.0.6" # 직접 지정해서 사용해도 되나, 같은 서브넷 안에서 만들어 질 수 없기 때문에 다 다르게 설정해야하는 귀찮음 때문에 삭제하고 자동으로 넣어주게 끔 한다.
    access_control_groups = [
        ncloud_vpc.prod-main.default_access_control_group_no,
        ncloud_access_control_group.web-prod.id,
    ]
}
# db
resource "ncloud_network_interface" "db-prod" {
    name                  = "db-prod-nic"
    description           = "for prod DB server"
    subnet_no             = ncloud_subnet.be-prod-server.id
    access_control_groups = [
        ncloud_vpc.prod-main.default_access_control_group_no,
        ncloud_access_control_group.db-prod.id,
    ]
}
## network interface setup for ACG end





## ACG: access control group setup start
// ncloud_access_control_group, ncloud_access_control_group_rule
# db
resource "ncloud_access_control_group" "db-prod" {
  name        = "lion-db-prod"
  description = "prod postgres db ACG"
  vpc_no      = ncloud_vpc.prod-main.vpc_no
}
# Inbound rule
resource "ncloud_access_control_group_rule" "db-acg-rule-prod" {
  access_control_group_no = ncloud_access_control_group.db-prod.id

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
resource "ncloud_access_control_group" "web-prod" {
  name        = "lion-web-prod"
  description = "prod web ACG"
  vpc_no      = ncloud_vpc.prod-main.vpc_no
}

# Inbound rule
resource "ncloud_access_control_group_rule" "web-acg-rule" {
  access_control_group_no = ncloud_access_control_group.web-prod.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "8000"
    description = "accept 8000 port for Django"
  }
}
## ACG: access control group setup end


