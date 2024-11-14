variable "lambda_role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to be used as the event source for the Lambda function"
  type        = string
}
