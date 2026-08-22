terraform {
  required_providers {
    helm       = { source = "hashicorp/helm", version = "~> 2.12" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.25" }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = { "app.kubernetes.io/name" = "argocd" }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.18"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [yamlencode({
    global = { domain = "argocd.${var.environment}.cloudops.local" }
    configs = {
      params = { "server.insecure" = true }
      cm = {
        "admin.enabled"                = true
        "application.resourceTrackingMethod" = "annotation"
        "timeout.reconciliation"       = "180s"
      }
    }
    server = {
      service = { type = "ClusterIP" }
      ingress = {
        enabled          = true
        ingressClassName = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
        hosts = ["argocd-${var.environment}.cloudops.local"]
      }
    }
    controller = { replicas = 1 }
    redis = { enabled = true }
  })]

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = "2.32.5"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [yamlencode({
    controller = { replicas = 1 }
  })]

  depends_on = [helm_release.argocd]
}
