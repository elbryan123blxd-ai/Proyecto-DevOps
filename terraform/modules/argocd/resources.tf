# Password admin encriptado con bcrypt: si no se provee uno, queda el default del chart.
locals {
  tags = merge(var.tags, { module = "argocd" })
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  atomic     = true
  timeout    = 900

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "server.replicas"
    value = "1"
  }

  dynamic "set" {
    for_each = var.admin_password != "" ? [1] : []
    content {
      name  = "configs.secret.argocdServerAdminPassword"
      value = var.admin_password
    }
  }

  depends_on = [kubernetes_namespace_v1.argocd]
}

resource "helm_release" "rollouts" {
  count      = var.install_rollouts ? 1 : 0
  name       = "argo-rollouts"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  atomic     = true
  timeout    = 900

  set {
    name  = "controller.replicas"
    value = "1"
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "image_updater" {
  count      = var.image_updater_enabled ? 1 : 0
  name       = "argo-image-updater"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = var.image_updater_chart_version
  atomic     = true
  timeout    = 600

  set {
    name  = "config.registries[0].name"
    value = "ECR"
  }

  set {
    name  = "config.registries[0].api_url"
    value = "https://499503541876.dkr.ecr.us-east-1.amazonaws.com"
  }

  set {
    name  = "config.registries[0].credentials"
    value = "default"
  }

  set {
    name  = "config.registries[0].prefix"
    value = "499503541876.dkr.ecr.us-east-1.amazonaws.com"
  }

  depends_on = [helm_release.argocd]
}