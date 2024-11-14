# Lambda Function for Image Generation
resource "aws_lambda_function" "image_generation_function" {
  function_name      = "image-generation-function"
  filename           = "lambda_sqs.zip"  # Adjust path if necessary
  role               = aws_iam_role.lambda_execution_role.arn  # Direct reference to IAM role ARN
  handler            = "lambda_sqs.lambda_handler"
  runtime            = "python3.9"
  timeout            = 15
  memory_size        = 128
  source_code_hash   = filebase64sha256("lambda_sqs.zip")  # Adjust path if necessary
  
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
