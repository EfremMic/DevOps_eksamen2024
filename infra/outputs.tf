output "lambda_function_name" {
  value = aws_lambda_function.image_processing_lambda.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.image_processing_lambda.arn
}

output "s3_bucket_name" {
  value = "pgr301-couch-explorers-erm"  # Direct output for the existing bucket
}
