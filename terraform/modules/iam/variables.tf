variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository in 'owner/repo' format allowed to assume the GHA role"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arns" {
  description = "A list of KMS key ARNs that the EKS nodes need access to"
  type        = list(string)
  default     = []
}
