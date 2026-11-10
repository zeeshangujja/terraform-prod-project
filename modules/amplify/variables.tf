variable "environment" { type = string }
variable "repository_url" { type = string }
variable "branch_name" { type = string }
variable "api_domain" { type = string }


variable "github_token" {
  type      = string
  sensitive = true
}