output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID used by EKS"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by EKS worker nodes"
  value       = module.vpc.private_subnets
}

output "api_ecr_url" {
  description = "ECR URL for API image"
  value       = aws_ecr_repository.api.repository_url
}

output "webhook_dns" {
  description = "Webhook DNS name"
  value       = aws_route53_record.bot.fqdn
}
