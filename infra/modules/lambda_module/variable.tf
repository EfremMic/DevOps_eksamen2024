variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda function"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}
