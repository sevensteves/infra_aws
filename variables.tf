variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default     = "sevensteves_cluster"
}

variable "ecs_sg_name" {
  description = "ECS security group name"
  default     = "sevensteves_ecs_sg"
}
