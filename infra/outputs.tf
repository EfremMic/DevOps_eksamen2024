output "sqs_queue_url" {
  value       = aws_sqs_queue.image_processing_queue.id
  description = "URL of the SQS queue"
}

output "lambda_function_name" {
  value       = aws_lambda_function.image_processor.function_name
  description = "Name of the Lambda function"
}

output "s3_bucket_name" {
  value       = "pgr301-couch-explorers"
  description = "Name of the S3 bucket for storing images"
}

