variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "ecs-assignment"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "flask_port" {
  description = "Container port for Flask backend"
  type        = number
  default     = 5000
}

variable "express_port" {
  description = "Container port for Express frontend"
  type        = number
  default     = 3000
}
