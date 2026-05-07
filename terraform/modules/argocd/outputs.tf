output "namespace" {
  value       = helm_release.argocd.namespace
  description = "The namespace where ArgoCD is deployed"
}

output "release_name" {
  value       = helm_release.argocd.name
  description = "The name of the ArgoCD Helm release"
}

output "platform_app_name" {
  value       = "localshop-platform"
  description = "The name of the platform application"
}
