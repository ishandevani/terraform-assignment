variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

variable "my_ip" {
  description = "My public IP address for SSH access"
  type        = string
}
