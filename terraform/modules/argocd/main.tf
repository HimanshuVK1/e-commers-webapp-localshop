resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.0.0"

  values = [
    yamlencode({
      server = {
        additionalProjects = [
          {
            name        = "localshop"
            namespace   = "argocd"
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
        additionalApplications = [
          {
            name      = "localshop-platform"
            namespace = "argocd"
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
          },
          {
            name      = "localshop-microservices"
            namespace = "argocd"
            project   = "localshop"
            source = {
              repoURL        = "https://github.com/${var.github_repo}.git"
              path           = "helm/localshop"
              targetRevision = "HEAD"
            }
            destination = {
              server    = "https://kubernetes.default.svc"
              namespace = "localshop"
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
      }
    })
  ]
}
