environment = "staging"
region      = "us-east-1"

# Password de RDS: NO va en este archivo (se pushea al repo).
# Pasarlo por env:  $env:TF_VAR_db_password="..." ; terraform plan

# Red
vpc_cidr             = "10.60.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.60.1.0/24", "10.60.2.0/24"]
private_subnet_cidrs = ["10.60.101.0/24", "10.60.102.0/24"]
enable_nat           = true

# DB
db_instance_class      = "db.t4g.micro"
db_multi_az            = false
db_deletion_protection = false

# EKS (nodos medianos)
node_instance_types = ["t3.medium"]
node_min_size       = 1
node_desired_size   = 2
node_max_size       = 4

# ArgoCD
argocd_chart_version = "7.8.4"
install_rollouts     = true