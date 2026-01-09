output "tf_state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "tf_lock_table" {
  value = aws_dynamodb_table.tf_lock.name
}

output "tf_state_kms_key_arn" {
  value       = var.enable_kms ? aws_kms_key.tf_state[0].arn : null
  description = "KMS key ARN if enable_kms=true"
}
