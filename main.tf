# Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.14"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Create ECS cluster
resource "aws_ecs_cluster" "sevensteves_cluster" {
  name = var.ecs_cluster_name
}

# Create Security Group
resource "aws_security_group" "sevensteves_ecs_sg" {
  name        = var.ecs_sg_name
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
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
}

# Use the existing IAM role via data source
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"  # Use the existing IAM role by name
}

# Uploading the infrastructure details to S3 as config.json
resource "null_resource" "upload_config" {
  provisioner "local-exec" {
    command = <<EOT
      echo '{
        "ecs_cluster_arn": "${aws_ecs_cluster.sevensteves_cluster.arn}",
        "vpc_id": "${module.vpc.vpc_id}",
        "subnet_ids": ["${join("\",\"", module.vpc.public_subnets)}"],
        "security_group_id": "${aws_security_group.sevensteves_ecs_sg.id}"
      }' > config.json
      aws s3 cp config.json s3://sevensteves-terraform-state-bucket/shared-config/config.json
    EOT
  }
}