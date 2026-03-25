terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "app_name" {
  type    = string
  default = "zlinebot"
}

resource "aws_instance" "app" {
  ami           = "ami-123456"
  instance_type = "t3.medium"

  tags = {
    Name = "${var.app_name}-app"
  }
}
