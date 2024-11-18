variable "aws_region" {
  default = "eu-west-1"
}

variable "bucket_name" {
  default = "pgr301-couch-explorers"
}


variable "sqs_queue_name" {
  description = "The name of the SQS queue"
}

variable "notification_email" {
  description = "The email address to receive alarm notifications"
  type        = string
  default     = "sensor-placeholder@example.com" # Placeholder email
}

variable "alarm_threshold" {
  description = "Threshold in seconds for triggering the CloudWatch alarm"
  default     = 5
}

variable "alarm_evaluation_periods" {
  description = "The number of periods for evaluating the alarm threshold"
  default     = 1
}
