terraform {
  backend "s3" {
    bucket = "pgr301-2024-terraform-state"  # Your S3 bucket
    key    = "lambda_sqs_state.tfstate"     # Path to the state file in the bucket
    region = "eu-west-1"                    # AWS region
    encrypt = true                          # Enable encryption for state file
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
    ignore_changes  = [assume_role_policy]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-image-processing-policy"
  description = "Policy to allow Lambda to access SQS, S3, and Bedrock model"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = "arn:aws:sqs:eu-west-1:123456789012:image-processing-queue"  # Replace with your SQS ARN
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::pgr301-couch-explorers-erm/*"  # Reference the existing bucket
      },
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"  # Replace with your Bedrock model ARN and region if necessary
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Upload lambda_sqs.zip to S3
resource "aws_s3_object" "lambda_code" {
  bucket = "pgr301-couch-explorers-erm"        # Your existing S3 bucket
  key    = "lambda_code/image_sqs_lambda.zip"  # Specify the path within the bucket
  source = "${path.module}/lambda_sqs.zip"     # Local path to lambda_sqs.zip
  acl    = "private"
}

# Lambda function using the uploaded S3 object
resource "aws_lambda_function" "image_processing_lambda" {
  function_name = "image-processing-lambda"
  s3_bucket     = "pgr301-couch-explorers-erm"      # Existing bucket
  s3_key        = aws_s3_object.lambda_code.key     # Refer to the uploaded object key

  handler = "lambda_sqs.lambda_handler"
  runtime = "python3.8"
  role    = aws_iam_role.lambda_execution_role.arn  # Use the IAM role ARN here

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers-erm"
    }
  }
  timeout = 30 

  # Ensure Lambda function is created only after the S3 object is uploaded
  depends_on = [aws_s3_object.lambda_code]
}
