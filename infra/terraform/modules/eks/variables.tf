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

variable "cluster_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.34"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for nodes"
  default     = ["t3.small"]
}

variable "node_desired_size" {
    type = number
    default = 1
}
variable "node_min_size"     {
    type = number
    default = 1
}
variable "node_max_size"     {
    type = number
    default = 2
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT"
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_subnet_type" {
  type        = string
  description = "public or private"
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.node_subnet_type)
    error_message = "node_subnet_type must be public or private."
  }
}

variable "cluster_public_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access EKS public API endpoint"
  default     = []
}
