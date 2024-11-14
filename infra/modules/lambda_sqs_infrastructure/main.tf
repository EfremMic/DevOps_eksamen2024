resource "aws_sqs_queue" "image_queue" {
  name                              = "image-generation-queue"
  visibility_timeout_seconds        = 30
  message_retention_seconds         = 345600
  max_message_size                  = 262144
  receive_wait_time_seconds         = 0
  delay_seconds                     = 0
}

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
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda-sqs-policy"
  description = "IAM policy for Lambda to access SQS and S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.image_queue.arn
      },
      {
        Action   = ["s3:PutObject", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::pgr301-couch-explorers-erm/*"
      }
    ]
  })
}

resource "aws_lambda_function" "image_generation_function" {
  function_name = "image-generation-function"
  handler       = "lambda_sqs.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  memory_size   = 128
  timeout       = 15

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers-erm"
    }
  }

  s3_bucket = "pgr301-couch-explorers-erm"
  s3_key    = "lambda_sqs.zip"
}

resource "aws_lambda_event_source_mapping" "sqs_event_trigger" {
  event_source_arn  = aws_sqs_queue.image_queue.arn
  function_name     = aws_lambda_function.image_generation_function.arn
  batch_size        = 5
  enabled           = true
}
