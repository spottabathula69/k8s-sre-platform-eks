variable "aws_region" {
  type        = string
  description = "AWS region for the deployment"
  default     = "us-west-2"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for tags/names"
  default     = "k8s-sre-platform"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}
