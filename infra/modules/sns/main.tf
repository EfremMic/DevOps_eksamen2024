resource "aws_sns_topic" "alarm_topic" {
  name = "cloudwatch-alarm-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

output "sns_topic_arn" {
  value = aws_sns_topic.alarm_topic.arn
}
