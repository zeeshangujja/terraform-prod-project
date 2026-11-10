variable "environment" { type = string }

variable "app_secrets" {
  type      = map(string)
  sensitive = true
}