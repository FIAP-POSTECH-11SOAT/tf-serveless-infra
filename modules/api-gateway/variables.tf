variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_gateway_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "api_gateway_stage_name" {
  description = "Stage name for API deployment"
  type        = string
  default     = "dev"
}

variable "api_gateway_lambda_functions" {
  description = "Map of Lambda functions"
  type        = any
}

variable "api_gateway_user_pool_arn" {
  description = "Cognito User Pool ARN for authorizer"
  type        = string
  default     = ""
}

variable "api_gateway_user_pool_id" {
  description = "Cognito User Pool ID for authorizer"
  type        = string
  default     = ""
}

variable "enable_vpc_link" {
  type    = bool
  default = false
}

variable "vpc_link_id" {
  type        = string
  default     = null
  description = "API Gateway VPC Link ID (required if enable_vpc_link = true)"
}

variable "vpc_link_backend_base_url" {
  type        = string
  default     = null
  description = "Base URL do backend interno atrás do NLB, ex: http://internal-nlb-123.us-east-1.elb.amazonaws.com"
}