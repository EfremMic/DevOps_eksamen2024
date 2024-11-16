# Define any input variables here

variable "bucket_name" {
  description = "The name of the S3 bucket where Lambda code is stored"
  type        = string
  default     = "pgr301-couch-explorers-erm"  # Default to your existing bucket name
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "image-processing-lambda"
}
