# outputs.tf

#Fetch Minikube IP using local-exec
resource "null_resource" "minikube_ip" {
  provisioner "local-exec" {
    command = "minikube ip > minikube_ip.txt"
  }
}

#Read Minikube IP from the file
data "local_file" "minikube_ip" {
  filename   = "minikube_ip.txt"
  depends_on = [null_resource.minikube_ip]
}

#Trim whitespace from the IP
locals {
  minikube_ip = trimspace(data.local_file.minikube_ip.content)
}


#Fetch Grafana Details
data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  depends_on = [helm_release.kube_prometheus_stack]
}

#Fetch Kibana service details
data "kubernetes_service" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }

  depends_on = [helm_release.kibana]
}


#Output Grafana URL
output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${local.minikube_ip}:${data.kubernetes_service.grafana.spec[0].port[0].node_port}"
}


#Output Kibana URL
output "kibana_url" {
  description = "URL to access Kibana"
  value       = "http://${local.minikube_ip}:${data.kubernetes_service.kibana.spec[0].port[0].node_port}"
}

#Output Nginx URL
output "nginx_url" {
  description = "URL to access Nginx"
  value       = "http://${local.minikube_ip}:${var.nginx_node_port}"
}
