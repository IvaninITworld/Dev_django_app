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

// Create a new server instance
resource "ncloud_login_key" "loginkey" {
  key_name = "test-key"
}

resource "ncloud_vpc" "main" {
  ipv4_cidr_block = "10.1.0.0/16"
  name = "lion-tf"
}

resource "ncloud_subnet" "main" {
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
  name = "lion-tf-sub"
}

resource "ncloud_server" "server" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "be-staging"
  server_image_product_code =  "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.products.server_products[0].product_code # 서버스펙 설정
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init.init_script_no
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

# 서버스펙 데이터 삽입
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

# init script
# variable "subnet_no" {}

resource "ncloud_init_script" "init" {
  name    = "set-docker-tf"
  content = <<EOT
#!/bin/bash

USERNAME="lion"
PASSWORD="1234"
REMOTE_DIRECTORY="/home/$USERNAME/"

echo "Add user"
useradd -s /bin/bash -d $REMOTE_DIRECTORY -m $USERNAME

echo "Set password"
echo "$USERNAME:$PASSWORD" | chpasswd

echo "Set sudo"
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

echo "Update apt and Install docker & docker-compose"
sudo apt-get update
sudo apt install -y docker.io docker-compose

echo "Start docker"
sudo service docker start && sudo service docker enable

echo "Add user to 'docker' group"
sudo usermod -aG docker $USERNAME

echo "done"
EOT
} # 인덴트가 진짜 중요하니까 꼭 맞춰서 넣기!


# DB instance 생성
resource "ncloud_server" "db" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "db-staging"
  server_image_product_code =  "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.products.server_products[0].product_code # 서버스펙 설정
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init.init_script_no
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