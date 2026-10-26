locals {
  name = "${var.project_name}-${var.environment}"
}

# Latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ---------- Security group: public EC2 ----------
resource "aws_security_group" "public" {
  name        = "${local.name}-public-ec2-sg"
  description = "SSH from my IP, HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-public-ec2-sg" }
}

# ---------- Security group: private EC2 ----------
resource "aws_security_group" "private" {
  name        = "${local.name}-private-ec2-sg"
  description = "SSH only from the public EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from public EC2 only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-private-ec2-sg" }
}

# ---------- Public EC2 ----------
resource "aws_instance" "public" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true

  tags = { Name = "${local.name}-public-ec2" }
}

# ---------- Private EC2 ----------
resource "aws_instance" "private" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = { Name = "${local.name}-private-ec2" }
}