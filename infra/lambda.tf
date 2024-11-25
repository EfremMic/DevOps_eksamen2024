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
