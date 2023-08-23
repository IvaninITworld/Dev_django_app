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

# SSH 로 서버에 접근할 때 쓰는 키 -> pem 키?
resource "ncloud_login_key" "loginkey-prod" {
  key_name = "test-key-prod"
}

## be backend server setup start
resource "ncloud_server" "be-prod-server" {
  subnet_no                 = ncloud_subnet.be-prod-server.id
  name                      = "be-prod-server"
  server_image_product_code = data.ncloud_server_products.products.server_image_product_code
  server_product_code       = data.ncloud_server_products.products.product_code
  login_key_name            = ncloud_login_key.loginkey-prod.key_name
  init_script_no = ncloud_init_script.be-prod.id

  network_interface {
    network_interface_no = ncloud_network_interface.web-prod.id
    order = 0
  }
}
resource "ncloud_public_ip" "we-prod" {
  server_instance_no = ncloud_server.be-prod-server.id
  description = "public IP for backend server prod"
}

output "backend_public_ip" {
  value = ncloud_public_ip.we-prod.public_ip
}
## be backend server setup end

## db server setup start
resource "ncloud_server" "db-prod-server" {
  subnet_no                 = ncloud_subnet.be-prod-server.id
  name                      = "db-prod-server"
  server_image_product_code = data.ncloud_server_products.products.server_image_product_code
  server_product_code       = data.ncloud_server_products.products.product_code
  login_key_name            = ncloud_login_key.loginkey-prod.key_name
  init_script_no = ncloud_init_script.db-prod.id

  network_interface {
    network_interface_no = ncloud_network_interface.db-prod.id
    order = 0
  }
}
resource "ncloud_public_ip" "db-prod" {
  server_instance_no = ncloud_server.db-prod-server.id
  description = "public IP for db server prod"
}
output "db_public_ip" {
  value = ncloud_public_ip.db-prod.public_ip
}
## db server setup end