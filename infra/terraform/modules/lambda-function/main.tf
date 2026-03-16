resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = var.role_arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  architectures = var.architectures

  filename         = var.zip_path
  source_code_hash = filebase64sha256(var.zip_path)

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size == null ? [] : [1]
    content {
      size = var.ephemeral_storage_size
    }
  }
}

resource "aws_lambda_permission" "invoke_from_lambda" {
  count = var.create_permission && var.source_lambda_arn != null ? 1 : 0

  statement_id  = var.statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = var.source_lambda_arn
}
