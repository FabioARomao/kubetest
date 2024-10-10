resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("values/argocd.yaml")]
}

resource "helm_release" "nginx" {
  name       = "my-nginx"
  repository = "https://charts.helm.sh/stable"
  chart      = "nginx-ingress"
  namespace  = "default"

  values = [
    <<EOF
controller:
  replicaCount: 1
EOF
  ]
}

resource "argocd_application" "kubetest" {
  metadata {
    name      = "kubetest"
    namespace = "argocd" # Namespace onde o ArgoCD está instalado
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/FabioARomao/kubetest.git" # Seu repositório Git
      target_revision = "main" # Branch a ser usada (ou tag)
      path            = "app/bijux.yml" # Caminho do código no repositório
    }

    destination {
      server    = "https://kubernetes.default.svc" # API server do Kubernetes
      namespace = "bijux-namespace" # Namespace do Kubernetes onde a aplicação será implantada
    }

    #sync_policy {
    #  #automated {
    #    prune = true  # Para remover recursos antigos que não estão mais no Git
    #    self_heal = true # Corrige automaticamente qualquer drift entre o estado real e o Git
    #  }
    #}
  }
}