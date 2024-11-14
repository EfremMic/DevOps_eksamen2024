# Define SQS Queue for Image Processing
resource "aws_sqs_queue" "image_queue" {
  name                       = "image-queue-candidate-86"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  max_message_size           = 262144
  receive_wait_time_seconds  = 0
  delay_seconds              = 0

  tags = {
    Environment = "development"
    Project     = "ImageGeneration"
  }
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Environment = "development"
    Project     = "ImageGeneration"
  }
}

# IAM Policy for Lambda to Access SQS, S3, and Bedrock
resource "aws_iam_policy" "lambda_image_processing_policy" {
  name        = "lambda-image-processing-policy"
  description = "IAM policy for Lambda to access SQS, S3, and Bedrock"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",  # Allow Lambda to receive messages from SQS
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.image_queue.arn
      },
      {
        Action   = ["s3:PutObject", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::pgr301-couch-explorers-erm/*"
      },
      {
        Action   = ["bedrock:InvokeModel"]
        Effect   = "Allow"
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

# Attach the IAM policy to the Lambda Execution Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_image_processing_policy.arn  # Attach new policy
}

# Attach AWS managed policy for basic Lambda execution
resource "aws_iam_role_policy_attachment" "basic_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Module
module "lambda_module" {
  source            = "./modules/lambda_module"
  lambda_role_arn   = aws_iam_role.lambda_execution_role.arn
  sqs_queue_arn     = aws_sqs_queue.image_queue.arn
}
