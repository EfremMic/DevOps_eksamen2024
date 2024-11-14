output "lambda_function_arn" {
  value = module.lambda_module.lambda_function_arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.image_queue.id
}
