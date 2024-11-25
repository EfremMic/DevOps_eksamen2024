resource "aws_sqs_queue" "image_processing_queue" {
  name = "image-processing-queue-candidate-86"
  visibility_timeout_seconds = 35
}
