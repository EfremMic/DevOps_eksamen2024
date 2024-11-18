variable "queue_name" {
  description = "The name of the SQS queue to monitor"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "threshold" {
  description = "The threshold for the ApproximateAgeOfOldestMessage metric"
  type        = number
  default = 1
}

variable "evaluation_periods" {
  description = "The number of evaluation periods for the alarm"
  type        = number
}

