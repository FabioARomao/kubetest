provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 3.0"
    }
  }
}

provider "argocd" {
  # Certifique-se de que o ArgoCD já está configurado e o provider do ArgoCD está disponível
  server_addr = "argocd.local:80"
  #host     = "https://argocd-server.argocd.svc" # Endereço do servidor ArgoCD
  username = "admin"
  password = "argocd" # Mude para seu password de admin
  insecure = true # Defina como true se estiver usando HTTP, ou falso se HTTPS
}