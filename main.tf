locals {
  lambda_functions = ["login", "register", "register-anonymous", "ping"]
}

#################################
# COGNITO
#################################

module "cognito" {
  source = "./modules/cognito"

  user_pool_name         = "my-app-users"
  app_client_name        = "my-app-spa"
  authenticated_role_arn = "arn:aws:iam::960227058929:role/LabRole"

  callback_urls = [
    "http://localhost:3000/callback"
  ]

  logout_urls = []

  enable_user_pool_domain = true
  domain_name             = null

  tags = {
    Environment = "dev"
    Project     = "my-app"
  }
}

#################################
# LAMBDAS
#################################

module "lambda_functions" {
  source = "./modules/lambda"

  for_each = toset(local.lambda_functions)

  lambda_function_name        = each.value
  lambda_source_dir           = "${path.root}/lambdas"
  lambda_cognito_client_id    = module.cognito.user_pool_client_id
  lambda_cognito_user_pool_id = module.cognito.user_pool_id
}

output "lambda_functions" {
  value = {
    for k, v in module.lambda_functions : k => {
      function_name = v.lambda_function_name
      function_arn  = v.lambda_function_arn
      invoke_arn    = v.lambda_invoke_arn
    }
  }
}

#################################
# VPC LINK
#################################
module "vpc_link" {
  source = "./modules/vpc-link"

  name            = "ab94c2a377c524a729a50c2e47f4dadd"
  target_nlb_arns = var.vpc_link_target_nlb_arns

  tags = {
    Environment = "dev"
    Project     = "my-app"
  }
}

#################################
# API-GATEWAY
#################################

module "api_gateway" {
  source = "./modules/api-gateway"

  api_gateway_name        = "auth-api"
  api_gateway_description = "Authentication API"
  api_gateway_stage_name  = "dev"

  api_gateway_lambda_functions = module.lambda_functions

  api_gateway_user_pool_arn = module.cognito.user_pool_arn
  api_gateway_user_pool_id  = module.cognito.user_pool_id

  enable_vpc_link           = true
  vpc_link_id               = module.vpc_link.vpc_link_id
  vpc_link_backend_base_url = var.vpc_link_backend_base_url

  depends_on = [module.lambda_functions, module.cognito, module.vpc_link]
}

output "api_gateway" {
  value = {
    api_gateway_id        = module.api_gateway.api_gateway_id
    api_gateway_url       = module.api_gateway.api_gateway_url
    api_gateway_stage_url = module.api_gateway.api_gateway_stage_url
  }
}

