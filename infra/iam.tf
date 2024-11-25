resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_candidate-86"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_sqs_s3_policy" {
  name = "lambda_sqs_s3_policy_candidate-86"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # SQS Permissions
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.image_processing_queue.arn
      },
      # S3 Permissions for the 86/ folder
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Resource = "arn:aws:s3:::pgr301-couch-explorers/86/*"
      },
      # Bedrock Permissions
      {
        Action = "bedrock:InvokeModel"
        Effect = "Allow"
        Resource = "*"
      },
      # CloudWatch Logs Permissions
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "arn:aws:logs:eu-west-1:*:*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sqs_s3_policy.arn
}
