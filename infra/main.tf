terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }

  backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "86/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

# SQS Queue
resource "aws_sqs_queue" "image_processing_queue" {
  name                       = "image-processing-queue-candidate-86"
  visibility_timeout_seconds = 30
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_candidate-86"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Full S3 Access
resource "aws_iam_policy" "s3_full_access_policy" {
  name = "s3_full_access_policy_candidate-86"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Full access to the Terraform backend bucket
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::pgr301-2024-terraform-state",
          "arn:aws:s3:::pgr301-2024-terraform-state/*"
        ]
      },
      # Full access to the Couch Explorers bucket
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::pgr301-couch-explorers",
          "arn:aws:s3:::pgr301-couch-explorers/*"
        ]
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "image_processor" {
  function_name    = "image_processor_lambda_candidate-86"
  runtime          = "python3.9"
  handler          = "lambda_sqs.lambda_handler"
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = "lambda/lambda_sqs.zip"
  source_code_hash = filebase64sha256("lambda/lambda_sqs.zip")

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
      S3_FOLDER   = "86"
    }
  }

  timeout = 30
}

# SQS to Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_processing_queue.arn
  function_name    = aws_lambda_function.image_processor.arn
  batch_size       = 10
}
