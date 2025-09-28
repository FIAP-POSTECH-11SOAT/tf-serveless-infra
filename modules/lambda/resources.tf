data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_source_dir}/${var.lambda_function_name}"
  output_path = "${path.module}/../../.terraform/tmp/${var.lambda_function_name}.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.lambda_function_name
  role          = "arn:aws:iam::960227058929:role/LabRole"
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  timeout       = 30
  memory_size   = 128

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CLIENT_ID    = var.lambda_cognito_client_id
      USER_POOL_ID = var.lambda_cognito_user_pool_id
    }
  }
}