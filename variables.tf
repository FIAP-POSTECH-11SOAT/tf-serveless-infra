variable "vpc_link_target_nlb_arns" {
  description = "EKS NLB ARN for VPC Link"
  type        = list(string)
}

variable "vpc_link_backend_base_url" {
  description = "EKS base URL for VPC Link"
  type        = string
}