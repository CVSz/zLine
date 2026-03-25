variable "project_name" {
  description = "Project identifier used for naming AWS resources."
  type        = string
  default     = "zlinebot"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for EKS and supporting resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "az_count" {
  description = "How many AZs to spread private/public subnets over."
  type        = number
  default     = 3
}

variable "kubernetes_version" {
  description = "EKS control plane version."
  type        = string
  default     = "1.30"
}

variable "cloudflare_zone" {
  description = "Cloudflare DNS zone name (e.g. zeaz.dev)."
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions."
  type        = string
  sensitive   = true
}

variable "cloudflare_tunnel_cname_target" {
  description = "Cloudflare tunnel UUID CNAME target (uuid.cfargotunnel.com)."
  type        = string
}

variable "domain_prefix" {
  description = "Subdomain for API/webhooks."
  type        = string
  default     = "bot"
}
