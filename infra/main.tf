# infra/main.tf
provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
   backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "lambda_sqs_state"
    region = "eu-west-1" 
  }
}



# Create the SQS Queue
resource "aws_sqs_queue" "image_generation_queue" {
  name = "image_generation_queue"
}

# Create the IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_image_generation_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

# Attach policy for SQS and S3 permissions
resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "lambda-policy-attach"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_sqs_policy" {
  name = "lambda_s3_sqs_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.image_generation_queue.arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::pgr301-couch-explorers/*"
      },
    ],
  })
}

# Create the Lambda function
resource "aws_lambda_function" "image_generator_lambda" {
  function_name = "image_generator_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_sqs.zip"  # Path to your zipped Lambda code
  timeout       = 20

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
    }
  }
}

# SQS and Lambda Integration
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_generation_queue.arn
  function_name    = aws_lambda_function.image_generator_lambda.arn
  batch_size       = 5
}
