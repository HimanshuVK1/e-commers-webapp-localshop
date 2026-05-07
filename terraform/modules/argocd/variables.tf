variable "github_repo" {
  type        = string
  description = "GitHub repository (format: owner/repo) to sync via ArgoCD"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repo))
    error_message = "The github_repo variable must be in the format 'owner/repo'."
  }
}

variable "argocd_version" {
  type        = string
  description = "The version of the ArgoCD Helm chart to deploy"
  default     = "7.7.0"
}

variable "namespace" {
  type        = string
  description = "The namespace to deploy ArgoCD into"
  default     = "argocd"
}
