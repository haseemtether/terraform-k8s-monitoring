# Create the monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Deploy Kube-Prometheus-Stack (includes Prometheus & Grafana)
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "kube-prometheus-stack"
  version    = "69.8.1"
  repository = "https://prometheus-community.github.io/helm-charts"
  wait       = true
  timeout    = 600

  values = [<<-EOT
    grafana:
      enabled: true
      adminPassword: "${var.grafana_admin_password}"  
      service:
        type: NodePort
        nodePort: ${var.grafana_nodeport}
      ingress:
        enabled: false
    prometheus:
      prometheusSpec:
        replicas: 1   # Reduce to a single instance
        retention: "24h"  # Reduce retention period to save space
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"

    alertmanager:
      enabled: true
      alertmanagerSpec:
        replicas: 1          

  EOT
  ]
}

