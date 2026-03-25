terraform {
  required_version = ">= 1.5.0"

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

resource "aws_instance" "zlinebot_app" {
  ami           = var.app_ami
  instance_type = "t3.medium"

  tags = {
    Name = "zlinebot"
    Env  = var.environment
  }
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "app_ami" {
  type        = string
  description = "AMI for zLineBot app node"
}
