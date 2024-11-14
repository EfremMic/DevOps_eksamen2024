# Reference the existing IAM role
data "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"  # Reference the existing role
}

# IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = data.aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::244530008913:policy/LambdaS3SQSPolicy"  # Reference existing policy
}

resource "aws_iam_role_policy_attachment" "basic_execution_policy_attachment" {
  role       = data.aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::244530008913:policy/service-role/AWSLambdaBasicExecutionRole-db4142bd-7291-4881-ad4a-83d13a358ffd"  # Reference the basic execution policy
}

# Reference the existing Lambda function
data "aws_lambda_function" "image_generation_function" {
  function_name = "image-generation-function"  # Reference the existing Lambda function
}

# Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_event_trigger" {
  event_source_arn = "arn:aws:sqs:eu-west-1:244530008913:image-generation-queue"
  function_name    = data.aws_lambda_function.image_generation_function.function_name
  batch_size       = 1
  enabled          = true
}
