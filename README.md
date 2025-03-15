# Kubernetes Monitoring & Logging with Terraform

## **Overview**
This project manages Kubernetes resources within a Minikube cluster using Terraform and deploys essential monitoring and logging tools. The deployment includes:

- **Prometheus & Grafana** for monitoring.
- **Nginx** with two pods exposed via a NodePort service.
- **Elasticsearch & Kibana** for log aggregation.
- **Fluent Bit**  for forwarding pod logs to Elasticsearch.

## **Prerequisites**
Ensure you have the following installed:
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## **Setup Instructions**

### **1. Start Minikube**
```sh
minikube start
```

### **2. Configure Kubeconfig**
Ensure your Kubernetes configuration is available at `~/.kube/config`.

### **3. Initialize Terraform**
Run the following commands inside the Terraform project directory:
```sh
terraform init
terraform plan
terraform apply -var "grafana_admin_password=<your_password>"
```

### **4. Deployment Components**
Terraform will provision the following:
- **Prometheus & Grafana**: Deployed via Helm charts.
- **Nginx Deployment**:
  - Runs **2 replicas** on port **80**.
  - Exposed via a **NodePort** service on port **30080**.
  - Returns the **pod IP** in both response body and a `server_ip` header.
- **Elasticsearch & Kibana**:
  - Stores logs from all Kubernetes pods.
- **Log Collection**:
  - Fluent Bit is configured to ship logs to Elasticsearch.

### **5. Accessing the Services**
Once deployment completes, Terraform outputs the URLs for the following services:
- **Grafana**: `http://<minikube-ip>:<grafana-port>`
- **Nginx**: `http://<minikube-ip>:30080`
- **Kibana**: `http://<minikube-ip>:<kibana-port>`

### **6. Validate Log Collection**
Check if logs are being ingested into Elasticsearch:
```sh
curl -X GET "http://<elasticsearch-ip>:9200/_cat/indices?v"
```

## **Terraform Providers**
The Terraform configuration expects Kubernetes to be set up and uses the following providers:
```hcl
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

## **Cleanup**
To remove all resources, run:
```sh
terraform destroy
```

---

