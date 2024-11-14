import base64
import boto3
import json
import random
import os

# AWS clients
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

# Constants
MODEL_ID = "amazon.titan-image-generator-v1"
BUCKET_NAME = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    try:
        # Log the received event for debugging purposes
        print("Received event:", event)

        # Process each SQS record in the event
        for record in event["Records"]:
            prompt = record.get("body", "default landscape")
            print(f"Processing prompt: {prompt}")

            # Generate a unique S3 path
            seed = random.randint(0, 2147483647)
            s3_image_path = f"images/titan_{seed}.png"

            # Prepare the request for image generation
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

            try:
                # Invoke Bedrock model for image generation
                response = bedrock_client.invoke_model(
                    modelId=MODEL_ID,
                    body=json.dumps(native_request)
                )
                model_response = json.loads(response["body"].read())
                base64_image_data = model_response["images"][0]
                image_data = base64.b64decode(base64_image_data)

                # Upload the generated image to S3
                s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
                print(f"Image successfully uploaded to S3 at path: {s3_image_path}")

            except bedrock_client.exceptions.ClientError as bedrock_error:
                print(f"Bedrock invocation failed: {bedrock_error}")
                return {
                    "statusCode": 400,
                    "body": json.dumps(f"Error generating image: {bedrock_error}")
                }

            except Exception as e:
                print(f"Unexpected error during image processing: {e}")
                return {
                    "statusCode": 500,
                    "body": json.dumps(f"Unexpected error: {str(e)}")
                }

    except Exception as e:
        print(f"General error in Lambda handler: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps(f"Lambda handler error: {str(e)}")
        }

    return {
        "statusCode": 200,
        "body": json.dumps("Image processing complete.")
    }
