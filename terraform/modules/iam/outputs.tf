output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}
