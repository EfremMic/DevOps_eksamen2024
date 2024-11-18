resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_alarm" {
  alarm_name          = "ApproximateAgeOfOldestMessage-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.threshold
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    QueueName = var.queue_name
  }
}

output "cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.sqs_oldest_message_alarm.alarm_name
}
