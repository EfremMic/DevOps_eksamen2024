output "lambda_function_arn" {
  value = data.aws_lambda_function.image_generation_function.arn
}

output "sqs_queue_url" {
  value = "https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue"
}
