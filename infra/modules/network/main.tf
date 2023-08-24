terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

# // Configure the ncloud provider
provider "ncloud" {
  access_key  = var.NCP_ACCESS_KEY
  secret_key  = var.NCP_SECRET_KEY
  region      = var.region
  site        = var.site
  support_vpc = var.support_vpc
}

## VPC setup start 
// cidr_block
resource "ncloud_vpc" "main" {
    name = "lion-${var.env}-tf"
    ipv4_cidr_block = "10.10.0.0/16"
}

resource "ncloud_network_acl" "nacl" {
    vpc_no = ncloud_vpc.main.id
}
## VPC setup end
