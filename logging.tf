# Create the logging namespace
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

# Deploy Elasticsearch Helm Chart
resource "helm_release" "elasticsearch" {
  name      = "elasticsearch"
  namespace = kubernetes_namespace.logging.metadata[0].name
  chart     = "./elasticsearch" # Path to the Elasticsearch Helm chart
  wait      = true
  timeout   = 600
}

# Deploy Kibana Helm Chart (depends on Elasticsearch)
resource "helm_release" "kibana" {
  name      = "kibana"
  namespace = kubernetes_namespace.logging.metadata[0].name
  chart     = "./kibana" # Path to the Kibana Helm chart
  wait      = true
  timeout   = 600

  depends_on = [helm_release.elasticsearch] # Ensure Elasticsearch is deployed first
}

# Deploy Fluent Bit Helm Chart (depends on Kibana)
resource "helm_release" "fluentbit" {
  name      = "fluentbit"
  namespace = kubernetes_namespace.logging.metadata[0].name
  chart     = "./fluent-bit" # Path to the Fluent Bit Helm chart
  wait      = true
  timeout   = 600

  depends_on = [helm_release.kibana] # Ensure Kibana is deployed first
}
