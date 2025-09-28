output "user_pool_id" {
  value       = aws_cognito_user_pool.user_pool.id
  description = "Cognito User Pool ID"
}

output "user_pool_client_id" {
  value       = aws_cognito_user_pool_client.app_client.id
  description = "Cognito App Client ID"
}

output "identity_pool_id" {
  value       = aws_cognito_identity_pool.identity_pool.id
  description = "Cognito Identity Pool ID"
}

output "hosted_ui_domain" {
  value       = try(aws_cognito_user_pool_domain.user_pool_domain[0].domain, null)
  description = "Hosted UI domain (if enabled)"
}

output "user_pool_arn" {
  value       = aws_cognito_user_pool.user_pool.arn
  description = "Cognito User Pool ARN"
}

output "user_pool_endpoint" {
  value       = aws_cognito_user_pool.user_pool.endpoint
  description = "Cognito User Pool Endpoint"
}