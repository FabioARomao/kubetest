resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("values/argocd.yaml")]
}

#resource "argocd_application" "kubetest" {
#  metadata {
#    name      = "kubetest"
#    namespace = "argocd" # Namespace onde o ArgoCD está instalado
#  }
#
#  spec {
#    project = "default"
#
#    source {
#      repo_url        = "https://github.com/FabioARomao/kubetest.git" # Seu repositório Git
#      target_revision = "main" # Branch a ser usada (ou tag)
#      path            = "app/bijux.yml" # Caminho do código no repositório
#    }
#
#    destination {
#      server    = "https://kubernetes.default.svc" # API server do Kubernetes
#      namespace = "bijux-namespace" # Namespace do Kubernetes onde a aplicação será implantada
#    }
#
#    #sync_policy {
#    #  #automated {
#    #    prune = true  # Para remover recursos antigos que não estão mais no Git
#    #    self_heal = true # Corrige automaticamente qualquer drift entre o estado real e o Git
#    #  }
#    #}
#  }
#}

resource "argocd_application" "kustomize" {
  metadata {
    name      = "kubetest"
    namespace = "argocd"
    labels = {
      test = "true"
    }
  }

  cascade = false # disable cascading deletion
  wait    = true

  spec {
    project = "default"

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "foo"
    }

    source {
      repo_url        = "https://github.com/FabioARomao/kubetest.git"
      path            = "examples/helloWorld"
      target_revision = "master"
      kustomize {
        name_prefix = "foo-"
        name_suffix = "-bar"
        images      = ["hashicorp/terraform:light"]
        common_labels = {
          "this.is.a.common" = "la-bel"
          "another.io/one"   = "true"
        }
      }
    }

    sync_policy {
      #automated {
      #  prune       = true
      #  self_heal   = true
      #  allow_empty = true
      #}
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false"]
      retry {
        limit = "5"
        #backoff {
        #  duration     = "30s"
        #  max_duration = "2m"
        #  factor       = "2"
        #}
      }
    }

    ignore_difference {
      group         = "apps"
      kind          = "Deployment"
      json_pointers = ["/spec/replicas"]
    }

    ignore_difference {
      group = "apps"
      kind  = "StatefulSet"
      name  = "someStatefulSet"
      json_pointers = [
        "/spec/replicas",
        "/spec/template/spec/metadata/labels/bar",
      ]
      # Only available from ArgoCD 2.1.0 onwards
      jq_path_expressions = [
        ".spec.replicas",
        ".spec.template.spec.metadata.labels.bar",
      ]
    }
  }
}