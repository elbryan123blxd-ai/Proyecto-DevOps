output "argocd_namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_host" {
  value = "argocd-${var.environment}.cloudops.local"
}

output "argo_rollouts_version" {
  value = helm_release.argo_rollouts.version
}
