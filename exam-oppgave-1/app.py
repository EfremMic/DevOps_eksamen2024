import os
import boto3
import json
import random
import base64

# AWS clients
s3_client = boto3.client("s3")
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")

BUCKET_NAME = os.environ["S3_BUCKET"]
MODEL_ID = os.environ["MODEL_ID"]

def lambda_handler(event, context):
    body = json.loads(event["body"])
    prompt = body.get("prompt")
    candidate_number = body.get("candidate_number")

    if not prompt or not candidate_number:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Prompt and candidate_number are required"})
        }

    seed = random.randint(0, 2147483647)
    s3_key = f"{candidate_number}/generated_image_{seed}.png"

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
        },
    }

    # Invoke Bedrock model
    response = bedrock_client.invoke_model(
        modelId=MODEL_ID,
        body=json.dumps(native_request)
    )
    model_response = json.loads(response["body"].read())
    base64_image_data = model_response["images"][0]
    image_data = base64.b64decode(base64_image_data)

    # Upload to S3
    s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_key, Body=image_data)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Image generated successfully",
            "s3_uri": f"s3://{BUCKET_NAME}/{s3_key}"
        })
    }
