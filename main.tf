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
resource "aws_ecs_cluster" "nginx_cluster" {
  name = var.ecs_cluster_name
}

# Create Security Group
resource "aws_security_group" "nginx_ecs_sg" {
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

# ECS Task Definition for nginx
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  # Use the existing ecsTaskExecutionRole
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions    = jsonencode([{
    name      = "nginx"
    image     = "nginx:latest"  # Use public image from Docker Hub
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

# ECS Service to run the nginx task
resource "aws_ecs_service" "nginx_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.nginx_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.nginx_ecs_sg.id]
    assign_public_ip = true
  }
}

