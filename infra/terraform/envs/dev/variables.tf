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

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnet egress (costly)"
  default     = false
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.34"
}

variable "node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for node group"
  default     = ["t3.small"]
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT (SPOT is cheaper but can be interrupted)"
  default     = "ON_DEMAND"
}

variable "node_subnet_type" {
  type        = string
  description = "Where to place nodes: public (cheapest, no NAT) or private (more prod-like, needs NAT for egress)"
  default     = "public"
}

variable "cluster_public_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access EKS public API endpoint"
  default     = []
}
