# variables.tf
variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "nginx_node_port" {
  description = "NodePort for the Nginx service"
  type        = number
  default     = 30080
}

variable "grafana_nodeport" {
  description = "NodePort for Grafana service"
  type        = number
  default     = 32000 #You can change this if needed
}
