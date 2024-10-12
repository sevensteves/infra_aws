variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default     = "nginx-cluster"  # Set the default name for the ECS cluster
}

variable "ecs_sg_name" {
  description = "ECS security group name"
  default     = "nginx-ecs-sg"  # Set the default name for the security group
}

variable "service_name" {
  description = "ECS service name"
  default     = "nginx-service"
}

variable "desired_count" {
  description = "Number of tasks to run"
  default     = 1
}
