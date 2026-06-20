variable "project_name" {
  type        = string
  description = "Project prefix used for naming/tagging"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "quarantine_sg_id" {
  type        = string
  description = "Security Group ID used for quarantine"
}

variable "victim_tag_key" {
  type        = string
  description = "Tag key to identify victim instance (fallback)"
}

variable "victim_tag_value" {
  type        = string
  description = "Tag value to identify victim instance (fallback)"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to resources"
}
