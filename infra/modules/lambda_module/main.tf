# Lambda Function for Image Generation
resource "aws_lambda_function" "image_generation_function" {
  function_name      = "ef-image-generation-function"
  filename           = "lambda_sqs.zip"  # Adjust path to the zip file containing Lambda code
  role               = var.lambda_role_arn  # Use the provided IAM role ARN variable
  handler            = "lambda_sqs.lambda_handler"
  runtime            = "python3.9"
  timeout            = 15
  memory_size        = 128
  source_code_hash   = filebase64sha256("lambda_sqs.zip")  # Adjust path if moved
  
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

# Event Source Mapping for SQS
resource "aws_lambda_event_source_mapping" "sqs_event_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.image_generation_function.arn
  batch_size       = 5
  enabled          = true
}
