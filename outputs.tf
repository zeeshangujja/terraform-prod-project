output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

##Add the outputs for ECR, ALB, RDS, and ECS modules here

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "rds_endpoint" {
  value = module.rds.address
}

output "rds_secret_arn" {
  value = module.rds.secret_arn
}
#Adding the ECS module outputs

output "public_ec2_ip" {
  value = module.ec2.public_ip
}

output "private_ec2_ip" {
  value = module.ec2.private_ip
}