variable "project_name" { type = string }
variable "environment"  { type = string }
variable "aws_region"   { type = string }

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "How many AZs to use (2 is enough for realism)"
  default     = 2
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)"
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)"
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnet egress (costly). Default false."
  default     = false
}
