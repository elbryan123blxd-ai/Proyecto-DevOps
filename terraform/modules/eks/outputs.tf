output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "CA base64 del cluster (para kubectl/providers k8s)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}

output "cluster_oidc_provider_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_arn" {
  value = aws_eks_node_group.this.arn
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}