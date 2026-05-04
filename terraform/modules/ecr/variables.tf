variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "services" {
  type = list(string)
  default = [
    "gateway", "frontend", "user-service", "product-service",
    "cart-service", "order-service", "inventory-service",
    "analytics-service", "payment-service", "notification-service"
  ]
}
