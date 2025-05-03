output "secret_key_arn" {
  description = "The ARN of the secret key"
  value       = aws_secretsmanager_secret.example.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.example.arn
}