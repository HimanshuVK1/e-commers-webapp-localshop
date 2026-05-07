resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.namespace
  create_namespace = true
  version          = var.argocd_version

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}

# Deploy initial Platform Application using argocd-apps chart
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = var.namespace
  version    = "2.0.2" # Latest stable for argocd-apps

  depends_on = [helm_release.argocd]

  values = [
    yamlencode({
      projects = [
        {
          name        = "localshop"
          namespace   = var.namespace
          description = "LocalShop Project"
          sourceRepos = ["*"]
          destinations = [
            {
              namespace = "*"
              server    = "https://kubernetes.default.svc"
            }
          ]
          clusterResourceWhitelist = [
            {
              group = "*"
              kind  = "*"
            }
          ]
        }
      ]
      applications = [
        {
          name      = "localshop-platform"
          namespace = var.namespace
          project   = "localshop"
          source = {
            repoURL        = "https://github.com/${var.github_repo}.git"
            path           = "platform"
            targetRevision = "HEAD"
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "platform"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = ["CreateNamespace=true"]
          }
        }
      ]
    })
  ]
}
