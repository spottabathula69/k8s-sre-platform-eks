output "vpc_id" {
  value       = null
  description = "VPC ID (wired in Step 2)"
}

output "public_subnet_ids" {
  value       = []
  description = "Public subnet IDs (wired in Step 2)"
}

output "private_subnet_ids" {
  value       = []
  description = "Private subnet IDs (wired in Step 2)"
}
