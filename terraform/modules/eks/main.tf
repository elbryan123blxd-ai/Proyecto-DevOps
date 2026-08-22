resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = var.eks_cluster_role_arn != null ? var.eks_cluster_role_arn : aws_iam_role.eks_cluster_fallback[0].arn
  version  = "1.31"

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = {
    Name        = var.eks_cluster_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "eks_cluster_fallback" {
  count = var.eks_cluster_role_arn == null ? 1 : 0
  name  = "${var.eks_cluster_name}-cluster-fallback"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_fallback_attach" {
  count      = var.eks_cluster_role_arn == null ? 1 : 0
  role       = aws_iam_role.eks_cluster_fallback[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "general-workers"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }
  disk_size = 20
  tags = {
    Name        = "${var.eks_cluster_name}-workers"
    Environment = var.environment
  }
}
