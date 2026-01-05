variable "project_name" { type = string }
variable "environment"  { type = string }

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet IDs"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet IDs"
  default     = []
}
