variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_source_dir" {
  description = "Directory containing Lambda source code"
  type        = string
}

variable "lambda_cognito_client_id" {
  description = "Cognito Client ID"
  type        = string
}

variable "lambda_cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}
