locals {
  tags = merge(var.tags, { module = "observability" })
}

# Datasource Loki para Grafana (Grafana lo instala kube-prometheus-stack)
locals {
  loki_datasource = {
    name      = "Loki"
    type      = "loki"
    access    = "proxy"
    url       = "http://loki.monitoring:3100"
    isDefault = false
  }
  grafana_extra = var.grafana_admin_password != "" ? { adminPassword = var.grafana_admin_password } : {}
  grafana_values = {
    grafana = merge(local.grafana_extra, {
      persistence = { enabled = false }
      additionalDataSources = [local.loki_datasource]
    })
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# --- Prometheus + Grafana + AlertManager ---
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_version
  atomic     = true
  timeout    = 900
  values     = [yamlencode(local.grafana_values)]

  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = "1"
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "2d"
  }

  set {
    name  = "prometheus.prometheusSpec.scrapeInterval"
    value = "30s"
  }

  set {
    name  = "prometheus.prometheusSpec.serviceType"
    value = "ClusterIP"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "384Mi"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.replicas"
    value = "1"
  }

  set {
    name  = "grafana.persistence.enabled"
    value = "false"
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# --- Loki (logs) en modo SingleBinary + promtail ---
resource "helm_release" "loki" {
  name       = "loki"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_version
  atomic     = true
  timeout    = 600

  # values YAML: más fiable que `set` para estructuras anidadas (emptyDir).
  values = [
    <<-EOT
deploymentMode: SingleBinary

# Modo SingleBinary puro: apagar los targets escalables (default del chart = 3).
read:
  replicas: 0
write:
  replicas: 0
backend:
  replicas: 0
singleBinary:
  replicas: 1
  persistence:
    enabled: false
  # Loki corre con readOnlyRootFilesystem: true; mountear un emptyDir en
  # /var/loki (path_prefix) para que pueda escribir chunks/índices.
  extraVolumes:
    - name: data
      emptyDir: {}
  extraVolumeMounts:
    - name: data
      mountPath: /var/loki

# Accesorios del chart que no hacen faltan en el demo (ahorran pods y memoria):
# gateway (nginx), caches memcached y loki-canary.
gateway:
  enabled: false
resultsCache:
  enabled: false
chunksCache:
  enabled: false
lokiCanary:
  enabled: false
test:
  enabled: false

loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  # Storage filesystem: sin buckets S3 (demo sin persistencia de logs).
  storage:
    type: filesystem
    filesystem:
      chunks_directory: /var/loki/chunks
  # Esquema de test: evita exigir schemaConfig/bucketNames completos.
  useTestSchema: true
EOT
  ]

  depends_on = [kubernetes_namespace_v1.monitoring]
}

resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.promtail_version
  atomic     = true
  timeout    = 600

  set {
    name  = "config.clients[0].url"
    value = "http://loki.monitoring:3100/loki/api/v1/push"
  }

  depends_on = [helm_release.loki]
}

# --- Ingress controller (último release estable; proyecto archivado pero funcional) ---
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace_v1.ingress_nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_version
  atomic     = true
  timeout    = 600

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  # ELB internal: nodos en subnets privadas; acceso por port-forward (patrón ArgoCD)
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.replicas"
    value = "1"
  }

  # Métricas expuestas (nivel de ingresos) + ServiceMonitor para que Prometheus las capture
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels.release"
    value = "kube-prometheus-stack"
  }

  depends_on = [kubernetes_namespace_v1.ingress_nginx, helm_release.kube_prometheus_stack]
}