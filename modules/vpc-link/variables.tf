variable "name" {
  type        = string
  description = "VPC Link name"
}

variable "target_nlb_arns" {
  type        = list(string)
  description = "List of NLB ARNs to attach to the VPC Link"
}

variable "tags" {
  type    = map(string)
  default = {}
}