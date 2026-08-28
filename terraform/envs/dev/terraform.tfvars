environment = "dev"
region      = "us-east-1"

# Password de RDS: NO va en este archivo (se pushea al repo).
# Pasarlo por env:  $env:TF_VAR_db_password="..." ; terraform plan

# Red
vpc_cidr             = "10.10.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
enable_nat           = true

# DB
db_instance_class      = "db.t4g.micro"
db_multi_az            = false
db_deletion_protection = false

# EKS (nodos tamaño medio para margen de RAM con ArgoCD+Rollouts)
# 2 nodos: 1 no alcanza para ArgoCD(9 pods) + kube-system(4) + app dev/staging/prod (18)
# Capacidad total t3.medium = 17 pods * 2 = 34 (necesario ~31). Reversible a 1 nodo en Fase 6 teardown.
# Fase 5 (observabilidad): +~10 pods de Prometheus/Grafana/Loki + ingress-nginx → 3er nodo (+$30/mes).
node_instance_types = ["t3.medium"]
node_min_size       = 3
node_desired_size   = 3
node_max_size       = 3

# ArgoCD
argocd_chart_version = "7.8.4"
install_rollouts     = true