module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

### Add the RDS,ECR or ECS&ALB module here

module "ecr" {
  source = "./modules/ECR"

  repository_name = var.ecr_repository_name
}

module "alb" {
  source = "./modules/ALB"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
  health_check_path = var.health_check_path
}

module "rds" {
  source = "./modules/RDS"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  allowed_sg_ids       = [module.ecs.security_group_id, module.ec2.private_sg_id]
  db_name              = var.db_name
  db_username          = var.db_username
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_port              = var.db_port
}

module "ecs" {
  source = "./modules/ECS"

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  ecr_repository_url = module.ecr.repository_url
  image_tag          = var.image_tag
  container_port     = var.container_port
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
  desired_count      = var.desired_count

  db_host       = module.rds.address
  db_port       = module.rds.port
  db_name       = var.db_name
  db_secret_arn = module.rds.secret_arn
}

#Adding the EC2 module to the main.tf file
module "ec2" {
  source = "./modules/EC2"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  private_subnet_id = module.vpc.private_subnet_ids[0]
  instance_type     = var.instance_type
  key_name          = var.key_name
  ssh_allowed_cidr  = var.ssh_allowed_cidr
}
