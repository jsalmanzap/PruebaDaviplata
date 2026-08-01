output "state_bucket_name" {
  description = "Nombre del bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "locks_table_name" {
  description = "Nombre de la tabla DynamoDB para los locks de Terraform"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "github_actions_role_arn" {
  description = "ARN del rol IAM para GitHub Actions (configurar como secret en el repo)"
  value       = aws_iam_role.github_actions.arn
}
