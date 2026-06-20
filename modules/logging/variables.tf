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
  description = "VPC ID to attach Flow Logs to"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to resources"
}
