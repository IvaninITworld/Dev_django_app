terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

# Create a VPC
resource "aws_vpc" "lion" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "lion-vpc"
  }
}


# Create IAM user
resource "aws_iam_user" "dev" {
  for_each = toset(["cat", "dog", "Tiger", "Eagle"])
  name = each.key
  path = "/dev/"

}

resource "aws_iam_access_key" "lion" {
  user = aws_iam_user.dev.name
}

data "aws_iam_policy_document" "lion_ro" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

# resource "aws_iam_user_policy" "lion_ro" {
#   name   = "tf-test"
#   user   = aws_iam_user.lion.name
#   policy = data.aws_iam_policy_document.lion_ro.json
# }

# # active console access
# resource "aws_iam_user_login_profile" "lion" {
#   user    = aws_iam_user.lion.name
# }

# output "password" {
#   value = aws_iam_user_login_profile.lion.password
#   sensitive = true # console 에서는 가려주자
# }

# # 유저정보를 출력하는 리소스
# resource "local_file" "users" {
#     content = "${aws_iam_user_login_profile.lion.password}"
#     filename = "${path.module}/users.txt"
# }