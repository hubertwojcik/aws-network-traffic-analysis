variable "project_name" {
  type        = string
  description = "Project prefix used for naming/tagging"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where instances and SGs will be created"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID for attacker instance"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID for victim instance"
}

variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to SSH (your IP /32)"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to resources"
}

variable "ssh_key_name" {
  type        = string
  description = "EC2 Key Pair name"
}