variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "aws_profile" {
  type    = string
  default = "sre-platform"
}

variable "project_name" {
  type    = string
  default = "k8s-sre-platform"
}

# Use one backend per account (recommended). Keep env out of bucket name.
variable "state_bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name for Terraform state"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"
  default     = "terraform-state-lock"
}

variable "enable_kms" {
  type        = bool
  description = "Use SSE-KMS instead of SSE-S3"
  default     = false
}

# Optional: restrict bucket access to a single principal ARN (user/role running Terraform).
# Leave null to allow any principal in the account (still secured by IAM).
variable "state_access_principal_arn" {
  type        = string
  description = "Optional principal ARN allowed to access the state bucket (tightest). If null, allow account root."
  default     = null
}

variable "noncurrent_version_expiration_days" {
  type        = number
  description = "Expire noncurrent object versions after N days to control costs"
  default     = 30
}

variable "abort_incomplete_multipart_upload_days" {
  type    = number
  default = 7
}
