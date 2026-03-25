module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "zlinebot-cluster"
  cluster_version = "1.29"

  vpc_id     = "vpc-xxxxxxxx"
  subnet_ids = ["subnet-aaaa", "subnet-bbbb"]

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}
