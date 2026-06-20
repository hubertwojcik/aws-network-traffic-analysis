variable "project_name" {
  type        = string
  description = "Project prefix used for naming/tagging"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to resources"
}
