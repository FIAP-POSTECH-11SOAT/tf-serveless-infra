output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com"
}

output "api_gateway_stage_url" {
  description = "Full URL of the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
}

output "api_gateway_authorizer_id" {
  description = "ID of the Cognito Authorizer"
  value       = aws_api_gateway_authorizer.cognito_authorizer.id
}

output "api_gateway_endpoints" {
  description = "Available endpoints"
  value = {
    public = [
      "POST ${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/auth/login",
      "POST ${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/auth/register",
      "POST ${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/auth/register-anonymous"
    ]
    protected = [
      "GET ${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/ping (requires Authorization header)"
    ]
  }
}