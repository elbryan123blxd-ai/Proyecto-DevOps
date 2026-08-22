module "vpc" {
  source = "../../modules/vpc"

  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
  vpc_name    = "cloudops-gym-dev"
}

module "ecr" {
  source = "../../modules/ecr"

  environment = "dev"
}

module "iam" {
  source = "../../modules/iam"

  environment      = "dev"
  eks_cluster_name = "cloudops-gym-dev-cluster"
}

module "rds" {
  source = "../../modules/rds"

  environment           = "dev"
  cluster_prefix        = "cloudops-gym-dev"
  rds_database_name     = "gymdb"
  rds_username          = var.rds_username
  rds_password          = var.rds_password
  rds_instance_class    = "db.t3.micro"
  rds_security_group_id = module.vpc.default_security_group_id
  private_subnet_ids    = module.vpc.private_subnets
}

module "eks" {
  source = "../../modules/eks"

  environment        = "dev"
  eks_cluster_name   = "cloudops-gym-dev-cluster"
  private_subnet_ids = module.vpc.private_subnets
  eks_node_role_arn  = module.iam.eks_node_role_arn
}


