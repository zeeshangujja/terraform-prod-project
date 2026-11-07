variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name, used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets (one per AZ)"
  type        = list(string)
}
## Variables for the RDS,ECR or ECS&ALB 

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_engine" {
  description = "RDS engine (mysql or postgres)"
  type        = string
}

variable "db_engine_version" {
  description = "RDS engine version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS storage in GB"
  type        = number
}

variable "db_port" {
  description = "Database port (3306 mysql, 5432 postgres)"
  type        = number
}

variable "container_port" {
  description = "Port the app listens on inside the container"
  type        = number
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
}

variable "container_cpu" {
  description = "Fargate task CPU units"
  type        = number
}

variable "container_memory" {
  description = "Fargate task memory in MB"
  type        = number
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
}

variable "image_tag" {
  description = "ECR image tag to deploy"
  type        = string
}

#Add any variable for EC2
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the public EC2"
  type        = string
}
variable "alert_email" {
  type = string
}