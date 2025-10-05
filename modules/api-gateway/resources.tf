# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_gateway_name
  description = var.api_gateway_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Cognito Authorizer (sempre criado se user_pool_arn for fornecido)
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name        = "${var.api_gateway_name}-cognito-authorizer"
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "COGNITO_USER_POOLS"

  provider_arns   = [var.api_gateway_user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

# /auth resource
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
}

# /auth/login resource
resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "login"
}

# POST /auth/login method
resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE" # Login é público
}

# LOGIN Lambda integration
resource "aws_api_gateway_integration" "login_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.api_gateway_lambda_functions["login"].lambda_invoke_arn
}

# /auth/register resource
resource "aws_api_gateway_resource" "register" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "register"
}

# POST /auth/register method
resource "aws_api_gateway_method" "register_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.register.id
  http_method   = "POST"
  authorization = "NONE" # Register é público
}

# REGISTER Lambda integration
resource "aws_api_gateway_integration" "register_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.api_gateway_lambda_functions["register"].lambda_invoke_arn
}

# /auth/register-anonymous resource
resource "aws_api_gateway_resource" "register_anonymous" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "register-anonymous"
}

# POST /auth/register-anonymous method
resource "aws_api_gateway_method" "register_anonymous_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.register_anonymous.id
  http_method   = "POST"
  authorization = "NONE" # Register anonymous é público
}

# REGISTER-ANONYMOUS Lambda integration
resource "aws_api_gateway_integration" "register_anonymous_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register_anonymous.id
  http_method = aws_api_gateway_method.register_anonymous_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.api_gateway_lambda_functions["register-anonymous"].lambda_invoke_arn
}

# PING Lambda integration
resource "aws_api_gateway_integration" "ping_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ping.id
  http_method = aws_api_gateway_method.ping_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.api_gateway_lambda_functions["ping"].lambda_invoke_arn
}

# ====================================
# EXEMPLO: ROTA PROTEGIDA (/ping)
# ====================================

# /ping resource (PROTEGIDO - exemplo)
resource "aws_api_gateway_resource" "ping" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "ping"
}

# GET /ping method (PROTEGIDO)
resource "aws_api_gateway_method" "ping_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ping.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# ====================================
# OPTIONS para CORS (mesmo código)
# ====================================

resource "aws_api_gateway_method" "auth_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "login_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "register_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.register.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "register_anonymous_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.register_anonymous.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS integrations (MOCK) - mesmo código
resource "aws_api_gateway_integration" "auth_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "login_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "register_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "register_anonymous_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register_anonymous.id
  http_method = aws_api_gateway_method.register_anonymous_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# Method responses e Integration responses para CORS - mesmo código do seu arquivo
resource "aws_api_gateway_method_response" "auth_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "login_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "register_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "register_anonymous_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register_anonymous.id
  http_method = aws_api_gateway_method.register_anonymous_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Integration responses para CORS - mesmo código
resource "aws_api_gateway_integration_response" "auth_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_options.http_method
  status_code = aws_api_gateway_method_response.auth_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.auth_options_integration]
}

resource "aws_api_gateway_integration_response" "login_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_options.http_method
  status_code = aws_api_gateway_method_response.login_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.login_options_integration]
}

resource "aws_api_gateway_integration_response" "register_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  status_code = aws_api_gateway_method_response.register_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.register_options_integration]
}

resource "aws_api_gateway_integration_response" "register_anonymous_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register_anonymous.id
  http_method = aws_api_gateway_method.register_anonymous_options.http_method
  status_code = aws_api_gateway_method_response.register_anonymous_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.register_anonymous_options_integration]
}

resource "aws_api_gateway_method" "ping_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ping.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ping_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ping.id
  http_method = aws_api_gateway_method.ping_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "ping_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ping.id
  http_method = aws_api_gateway_method.ping_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "ping_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ping.id
  http_method = aws_api_gateway_method.ping_options.http_method
  status_code = aws_api_gateway_method_response.ping_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.ping_options_integration]
}

# ================================
# PROXY protegido para backend EKS via VPC LINK
#   Rota: /app/{proxy+}
# ================================
resource "aws_api_gateway_resource" "app_proxy" {
  count       = var.enable_vpc_link ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# ANY /app/{proxy+} (PROTEGIDO por Cognito)
resource "aws_api_gateway_method" "app_any" {
  count         = var.enable_vpc_link ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.app_proxy[0].id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Integração HTTP_PROXY via VPC_LINK
resource "aws_api_gateway_integration" "app_any_integration" {
  count       = var.enable_vpc_link ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.app_proxy[0].id
  http_method = aws_api_gateway_method.app_any[0].http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.vpc_link_backend_base_url}/{proxy}"

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# OPTIONS para CORS em /app/{proxy+} (se quiser liberar do seu front)
resource "aws_api_gateway_method" "app_options" {
  count         = var.enable_vpc_link ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.app_proxy[0].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "app_options_integration" {
  count       = var.enable_vpc_link ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.app_proxy[0].id
  http_method = aws_api_gateway_method.app_options[0].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "app_options_200" {
  count       = var.enable_vpc_link ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.app_proxy[0].id
  http_method = aws_api_gateway_method.app_options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "app_options_integration_response" {
  count       = var.enable_vpc_link ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.app_proxy[0].id
  http_method = aws_api_gateway_method.app_options[0].http_method
  status_code = aws_api_gateway_method_response.app_options_200[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Requested-With'"
  }

  depends_on = [aws_api_gateway_integration.app_options_integration]
}

# Lambda permissions para API Gateway
resource "aws_lambda_permission" "login_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-login"
  action        = "lambda:InvokeFunction"
  function_name = var.api_gateway_lambda_functions["login"].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "register_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-register"
  action        = "lambda:InvokeFunction"
  function_name = var.api_gateway_lambda_functions["register"].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "register_anonymous_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-register-anonymous"
  action        = "lambda:InvokeFunction"
  function_name = var.api_gateway_lambda_functions["register-anonymous"].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "ping_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-ping"
  action        = "lambda:InvokeFunction"
  function_name = var.api_gateway_lambda_functions["ping"].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/ping"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.login_post,
    aws_api_gateway_integration.login_integration,
    aws_api_gateway_method.register_post,
    aws_api_gateway_integration.register_integration,
    aws_api_gateway_method.register_anonymous_post,
    aws_api_gateway_integration.register_anonymous_integration,
    aws_api_gateway_method.login_options,
    aws_api_gateway_integration.login_options_integration,
    aws_api_gateway_method.register_options,
    aws_api_gateway_integration.register_options_integration,
    aws_api_gateway_method.register_anonymous_options,
    aws_api_gateway_integration.register_anonymous_options_integration,
    aws_api_gateway_method.ping_get,
    aws_api_gateway_integration.ping_integration,
    aws_api_gateway_method.ping_options,
    aws_api_gateway_integration.ping_options_integration,

    # recursos opcionais (ok referenciar mesmo com count = 0)
    aws_api_gateway_method.app_any,
    aws_api_gateway_integration.app_any_integration,
    aws_api_gateway_method.app_options,
    aws_api_gateway_integration.app_options_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(concat([
      aws_api_gateway_resource.auth.id,
      aws_api_gateway_resource.login.id,
      aws_api_gateway_resource.register.id,
      aws_api_gateway_resource.register_anonymous.id,
      aws_api_gateway_method.login_post.id,
      aws_api_gateway_method.register_post.id,
      aws_api_gateway_method.register_anonymous_post.id,
      aws_api_gateway_integration.login_integration.id,
      aws_api_gateway_integration.register_integration.id,
      aws_api_gateway_integration.register_anonymous_integration.id,
      aws_api_gateway_resource.ping.id,
      aws_api_gateway_method.ping_get.id,
      aws_api_gateway_integration.ping_integration.id,
      aws_api_gateway_method.ping_options.id,
      aws_api_gateway_integration.ping_options_integration.id,
      aws_api_gateway_method_response.ping_options_200.id,
      aws_api_gateway_integration_response.ping_options_integration_response.id,
      ],
      # blocos opcionais via splat (viram [] quando count=0)
      aws_api_gateway_resource.app_proxy[*].id,
      aws_api_gateway_method.app_any[*].id,
      aws_api_gateway_integration.app_any_integration[*].id,
      aws_api_gateway_method.app_options[*].id,
      aws_api_gateway_integration.app_options_integration[*].id,
      aws_api_gateway_method_response.app_options_200[*].id,
      aws_api_gateway_integration_response.app_options_integration_response[*].id
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.api_gateway_stage_name
}