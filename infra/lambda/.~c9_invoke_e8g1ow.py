import base64
import boto3
import json
import random
import os
import logging


# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS clients
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

# Environment variables
MODEL_ID = os.environ.get("MODEL_ID", "amazon.titan-image-generator-v1")
BUCKET_NAME = os.environ.get("BUCKET_NAME", "pgr301-couch-explorers")

def lambda_handler(event, context):
    logger.info("Lambda triggered with event: %s", event)

    # Loop through all SQS records in the event
    for record in event["Records"]:
        try:
            # Extract the SQS message body
            prompt = record["body"]
            logger.info("Received prompt: %s", prompt)

            # Generate a random seed for the image
            seed = random.randint(0, 2147483647)

            # Define the S3 path including candidate folder
            candidate_folder = "86"
            s3_image_path = f"{candidate_folder}/generated_image_{seed}.png"
            logger.info("Generated S3 path: %s", s3_image_path)

            # Prepare the request for Bedrock image generation
            native_request = {
                "taskType": "TEXT_IMAGE",
                "textToImageParams": {"text": prompt},
                "imageGenerationConfig": {
                    "numberOfImages": 1,
                    "quality": "standard",
                    "cfgScale": 8.0,
                    "height": 512,
                    "width": 512,
                    "seed": seed,
                },
            }

            # Invoke the Bedrock model
            logger.info("Invoking Bedrock model: %s", MODEL_ID)
            response = bedrock_client.invoke_model(
                modelId=MODEL_ID,
                body=json.dumps(native_request)
            )

            # Decode the Bedrock response
            model_response = json.loads(response["body"].read())
            base64_image_data = model_response["images"][0]
            image_data = base64.b64decode(base64_image_data)
            logger.info("Image generation successful")

            # Upload the image to S3
            logger.info("Uploading image to S3 bucket: %s", BUCKET_NAME)
            s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
            logger.info("Image successfully uploaded to S3: %s", s3_image_path)

        except Exception as e:
            logger.error("Error processing record: %s", e, exc_info=True)

    return {
        "statusCode": 200,
        "body": json.dumps("Image generation request processed.")
    }
