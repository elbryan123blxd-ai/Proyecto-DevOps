module "vpc" {
  source = "../../modules/vpc"

  environment = "staging"
  vpc_cidr    = "10.1.0.0/16"
  vpc_name    = "cloudops-gym-staging"
}

module "ecr" {
  source = "../../modules/ecr"

  environment = "staging"
}

module "iam" {
  source = "../../modules/iam"

  environment      = "staging"
  eks_cluster_name = "cloudops-gym-staging-cluster"
}

module "rds" {
  source = "../../modules/rds"

  environment           = "staging"
  cluster_prefix        = "cloudops-gym-staging"
  rds_database_name     = "gymdb"
  rds_username          = var.rds_username
  rds_password          = var.rds_password
  rds_instance_class    = "db.t3.micro"
  rds_security_group_id = module.vpc.default_security_group_id
  private_subnet_ids    = module.vpc.private_subnets
}

module "eks" {
  source = "../../modules/eks"

  environment        = "staging"
  eks_cluster_name   = "cloudops-gym-staging-cluster"
  private_subnet_ids = module.vpc.private_subnets
  eks_node_role_arn  = module.iam.eks_node_role_arn
}

module "argocd" {
  source = "../../modules/argocd"

  environment          = "staging"
  eks_cluster_name     = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
}
