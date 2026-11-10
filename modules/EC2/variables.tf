variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_id" { type = string }
variable "private_subnet_id" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "ssh_allowed_cidr" { type = string }