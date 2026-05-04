variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "database_subnets" { type = list(string) }
variable "db_password" {
  type      = string
  sensitive = true
}
