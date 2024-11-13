import base64
import boto3
import json
import random
import os

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

model_id = "amazon.titan-image-generator-v1"

# Get the S3 bucket name from environment variable
bucket_name = os.getenv("BUCKET_NAME")

def lambda_handler(event, context):
    # Parse the incoming request to get the prompt
    try:
        body = json.loads(event['body'])
        prompt = body.get("prompt", "A scenic view")
    except (json.JSONDecodeError, KeyError):
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid request format. Please provide a prompt in JSON format."})
        }

    # Generate a unique seed for the image
    seed = random.randint(0, 2147483647)
    s3_image_path = f"generated_images/titan_{seed}.png"

    # Define the request for image generation
    native_request = {
        "taskType": "TEXT_IMAGE",
        "textToImageParams": {"text": prompt},
        "imageGenerationConfig": {
            "numberOfImages": 1,
            "quality": "standard",
            "cfgScale": 8.0,
            "height": 1024,
            "width": 1024,
            "seed": seed,
        }
    }

    # Call the model to generate an image
    try:
        response = bedrock_client.invoke_model(modelId=model_id, body=json.dumps(native_request))
        model_response = json.loads(response["body"].read())
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Failed to generate image", "error": str(e)})
        }

    # Upload the decoded image data to S3
    try:
        s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Failed to upload image to S3", "error": str(e)})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Image generated successfully",
            "s3_uri": f"s3://{bucket_name}/{s3_image_path}"
        })
    }
