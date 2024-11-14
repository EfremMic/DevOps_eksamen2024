# Check if the Lambda function already exists
data "aws_lambda_function" "existing_lambda_function" {
  function_name = "ef-image-generation-function"
}

# Lambda Function for Image Generation
resource "aws_lambda_function" "image_generation_function" {
  count             = data.aws_lambda_function.existing_lambda_function.function_name != "" ? 0 : 1
  function_name     = "ef-image-generation-function"
  filename          = "lambda_sqs.zip"
  role              = var.lambda_role_arn
  handler           = "lambda_sqs.lambda_handler"
  runtime           = "python3.9"
  timeout           = 15
  memory_size       = 128
  source_code_hash  = filebase64sha256("lambda_sqs.zip")

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers-erm"
    }
  }

  tags = {
    Environment = "development"
    Project     = "ImageGeneration"
  }
}

# Use a local variable to conditionally get the Lambda ARN
locals {
  lambda_function_arn = length(aws_lambda_function.image_generation_function) > 0 ? aws_lambda_function.image_generation_function[0].arn : data.aws_lambda_function.existing_lambda_function.arn
}

# Lambda Event Source Mapping for SQS
resource "aws_lambda_event_source_mapping" "sqs_event_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = local.lambda_function_arn  # Use the local variable for Lambda ARN
  batch_size       = 5
  enabled          = true
}

# Output Lambda Function ARN
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = local.lambda_function_arn  # Use the local variable for Lambda ARN
}
