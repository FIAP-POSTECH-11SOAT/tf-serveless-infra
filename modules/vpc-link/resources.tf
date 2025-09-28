resource "aws_api_gateway_vpc_link" "this" {
  name        = var.name
  target_arns = var.target_nlb_arns
  tags        = var.tags
}