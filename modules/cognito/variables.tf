variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "app_client_name" {
  description = "Name of the Cognito User Pool App Client (SPA)"
  type        = string
}

variable "password_policy" {
  description = "Password policy for the user pool"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_numbers   = bool
    require_symbols   = bool
    require_uppercase = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  validation {
    condition     = var.password_policy.minimum_length >= 6
    error_message = "minimum_length must be >= 6."
  }
}

variable "callback_urls" {
  description = "OAuth callback URLs for the SPA (implicit flow requires at least one)"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "OAuth logout URLs for the SPA"
  type        = list(string)
  default     = []
}

variable "enable_user_pool_domain" {
  description = "Create a hosted UI domain"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom hosted UI domain (null to auto-generate)"
  type        = string
  default     = null
}

variable "authenticated_role_arn" {
  description = "Existing IAM role ARN for authenticated identities (e.g., arn:aws:iam::XXX:role/LabRole)"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role\\/.+", var.authenticated_role_arn))
    error_message = "authenticated_role_arn must be a valid IAM role ARN."
  }
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = { Environment = "dev" }
}