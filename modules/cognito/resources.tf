data "aws_region" "current" {}

resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_lowercase = var.password_policy.require_lowercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
    require_uppercase = var.password_policy.require_uppercase
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "document"
    attribute_data_type = "String"
    mutable             = true
    string_attribute_constraints {
      min_length = 11
      max_length = 14
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false

    invite_message_template {
      email_subject = "Temporary password"
      email_message = "Your temporary username is {username} and temporary password is {####}"
      sms_message   = "Your temporary username is {username} and temporary password is {####}"
    }
  }

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  tags = merge(var.tags, {
    Name      = var.user_pool_name
    ManagedBy = "terraform"
  })
}

resource "aws_cognito_user_pool_client" "app_client" {
  name         = var.app_client_name
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_AUTH",     # Para login direto via API
    "ALLOW_USER_SRP_AUTH", # Para login com usuário/senha
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH" # Para refresh tokens
  ]

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  allowed_oauth_scopes = [
    "email",
    "openid",
  ]

  read_attributes = [
    "email",
    "email_verified",
    "name"
  ]

  write_attributes = [
    "email",
    "name"
  ]
}

resource "random_string" "domain_suffix" {
  count   = var.enable_user_pool_domain && var.domain_name == null ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  count        = var.enable_user_pool_domain ? 1 : 0
  domain       = var.domain_name != null ? var.domain_name : "${var.user_pool_name}-${random_string.domain_suffix[0].result}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.user_pool_name}-identity"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    provider_name           = aws_cognito_user_pool.user_pool.endpoint
    client_id               = aws_cognito_user_pool_client.app_client.id
    server_side_token_check = false
  }

  tags = merge(var.tags, {
    Name      = "${var.user_pool_name}-identity"
    ManagedBy = "terraform"
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    authenticated = var.authenticated_role_arn
  }
}
