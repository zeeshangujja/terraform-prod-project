terraform {
  backend "s3" {
    bucket       = "s3-terraform-state.tf-my-prod"
    key          = "project1/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true # S3 native locking (Terraform 1.10+), no DynamoDB needed
  }
} 