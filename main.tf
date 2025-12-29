provider "kubernetes" {
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
  host                   = var.kubernetes_cluster_endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
  }
}

provider "helm" {
  kubernetes = {
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
    }
  }
}

resource "kubernetes_namespace_v1" "argocd-namespace" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.7.0"

  # namespace = "argocd"
  namespace  = kubernetes_namespace_v1.argocd-namespace.metadata[0].name
  depends_on = [kubernetes_namespace_v1.argocd-namespace]
}