resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name    = "nginx"
          image   = "nginx:latest"
          command = ["/bin/sh"]
          args = [
            "-c",
            <<-EOC
            # Replace $MY_POD_IP in default.conf.template -> default.conf
            envsubst '$MY_POD_IP' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
            nginx -g 'daemon off;'
            EOC
          ]

          port {
            container_port = 80
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d/default.conf.template"
            sub_path   = "default.conf.template"
          }

          env {
            name = "MY_POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name = "nginx-config"
  }

  data = {
    "default.conf.template" = <<-EOT
      server {
        listen 80;
        default_type text/plain;
        location / {
          add_header server_ip $MY_POD_IP;
          return 200 "Pod IP: $MY_POD_IP\n";
        }
      }
    EOT
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = var.nginx_node_port
    }

    type = "NodePort"
  }
}
