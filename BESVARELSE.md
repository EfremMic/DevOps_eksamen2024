# BESVARELSE.md

## Candidate No.: 86

### OPPGAVE 1

#### Oppgave 1A - API URL

We can retrieve the URL of API Gateway directly from CloudFormation outputs or we can use the AWS CLI to retrieve the URL. I chose the latter option:

```sh
aws cloudformation describe-stacks --stack-name couch-explorers-lambda-rem-2024 --query "Stacks[0].Outputs[?OutputKey=='ImageGenerationApi'].OutputValue" --region eu-west-1
```

**API URL:** `https://htq4lxo5pk.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/`

**Test in Postman:**

- Create a new collection or use an existing one, and make a POST request using the URL.
- Set the request body to "raw" and select JSON format.
- Enter the following JSON request body:

  ```json
  {
    "prompt": "Generate a dog riding a bike",
    "candidate_number": "86"
  }
  ```

- You should receive a status of 200.
- The generated image can be found inside the bucket `Buckets/pgr301-couch-explorers/86`.

#### Oppgave 1B - GitHub Actions Workflow

Link to a working GitHub Actions workflow which has deployed the SAM application to AWS: **Deploy SAM Application · Workflow runs · EfremMic/DevOps_eksamen2024**


### OPPGAVE 2

**Links to Terraform Deploy**

- **GitHub Actions workflow - main branch**
- **Update Terraform configuration and reset infrastructure:** EfremMic/DevOps_eksamen2024@29d7142
- **GitHub Actions workflow - feature/test-plan branch**
- **Update Terraform configuration and reset infrastructure:** EfremMic/DevOps_eksamen2024@6a6a7f3

**SQS Queue URL**

`https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-candidate-86`

**SQS Sending & Receiving Test**

- **Sending a message to the queue**
- **Receiving the message:** For testing purposes, I had to add `--attributes VisibilityTimeout=3` to receive the message before it is consumed.

**NB! Potential Error when running the application using Terraform**

If you choose to run the application by initializing and applying Terraform, you might come across an error during `terraform apply` related to IAM roles or policies. This occurs because Terraform attempts to create an IAM role or policy that already exists in my AWS account. To resolve this issue, you can import the IAM role and IAM policy using the following commands:

- Import IAM Role:
  ```sh
  terraform import aws_iam_role.example_role_name arn:aws:iam::ACCOUNT_ID:role/example_role_name
  ```
- Import IAM Policy:
  ```sh
  terraform import aws_iam_policy.example_policy_name arn:aws:iam::ACCOUNT_ID:policy/example_policy_name
  ```

Replace `ACCOUNT_ID` with the account ID found in `variables_and_credentials.pdf`.

**Terraform State File**

Can be found in `pgr301-2024-terraform-state/86`.


### OPPGAVE 3

**Tagging Strategy**

- **Latest:** This tag points to the latest image built on the main branch, allowing the team to pull the latest version without specifying a specific tag.
- **vX.X.X (Semantic Versioning):** Provides flexibility. The team can access both the latest image and specific, stable versions. Examples:
  - `v1.0.0` for the first release
  - `v1.0.1` for updates
  - `v2.0.0` for significant changes

**Reason:** This strategy offers flexibility by allowing team members to access both the latest image and a specific version.

**Container Image / Docker Hub Image**

Docker Hub repo: `efmi002/java-sqs-client`

**SQS URL**

`https://sqs.eu-west-1.amazonaws.com/244530008913/image-queue-candidate-86`

**Solution Test**

1. **Run the image:** Pull and run the image with your AWS credentials:

    ```sh
    docker run -e AWS_ACCESS_KEY_ID=xxx \
              -e AWS_SECRET_ACCESS_KEY=yyy \
              -e SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/244530008913/image-queue-candidate-86 \
              efmi002/java-sqs-client:latest \
              "me on top of a pyramid"
    ```

    This will send a message to the SQS queue.

**Queue Accessibility**

The SQS queue has been made public for 60 days to facilitate testing.

**Docker Hub**

Docker Hub repo: [efmi002/java-sqs-client](https://hub.docker.com/r/efmi002/java-sqs-client)


### OPPGAVE 4

**Metrics and Monitoring**

**Structure**

As suggested in the exam question, I expanded my exam answer for question 2 by modularizing the Terraform configuration for better scalability and reusability.

**Variables**

To ensure flexibility, I use `terraform.tfvars` to manage values, allowing for easy changes to variables such as `email` and `sqs_queue_name`.

**Terraform Modules Folder**

Contains the following:

- **CloudWatch Folder:** `main.tf` and `variable.tf` for setting up alarms.
- **SNS Folder:** `main.tf` and `variable.tf` for creating topics and subscriptions for email notifications.
- **Variables.tf:** Created in each folder to define values.

**Verification of Setup**

After applying the configuration, I received an email notification with a subscription link, which I accepted to start receiving alerts. For testing purposes, I set the `alarm_threshold` to `5` and `alarm_evaluation_periods` to `1` in `terraform.tfvars` in the root folder. These values are intended to be set to a standard of `alarm_threshold = 60` and `alarm_evaluation_periods = 2` or more.

I was also able to verify the alarm creation and monitor the SQS queue in the AWS CloudWatch Console under Alarms.

**Simulation of the Alarm**

Upon each commit, Terraform applies the configuration. Replace the values for `notification_email` and `sqs_queue_name` via GitHub Secret (you can use your own email).

**Test**

- `lambda_function_name = "image_processor_lambda_candidate-86"`
- `s3_bucket_name = "pgr301-couch-explorers"`
- `sqs_queue_url = "https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-candidate-86"`


### OPPGAVE 5

**Serverless vs. Microservices Architecture - DevOps Implications**

**Automation and Continuous Delivery (CI/CD)**

- **Serverless Architecture:** Integrating CI/CD in a serverless architecture has advantages like better control over small deployable units and faster deployment without infrastructure management. However, with production growth and dependencies, managing the CI/CD pipeline can become complex.
- **Microservices Architecture:** Microservices operate independently, making CI/CD management more straightforward at the service level, with effective deployment strategies. However, the need for managing networking and clusters increases automation complexity. The risks in deployment are higher due to interdependencies, and rollbacks can be challenging.

**Observability**

- **Serverless Architecture:** Tools like AWS CloudWatch Logs and Metrics provide monitoring, debugging, and troubleshooting for serverless functions. However, due to their ephemeral nature, achieving end-to-end visibility can be difficult.
- **Microservices Architecture:** Microservices benefit from isolated observability, but debugging and monitoring are more dependent on service-specific tools and strategies.

**Scalability and Cost Control**

- **Serverless Architecture:** Offers automatic scaling and cost efficiency since charges are based on compute time. However, debugging and monitoring can be challenging.
- **Microservices Architecture:** Allows independent scaling, providing control over resource allocation, but this often requires complex infrastructures, leading to higher costs.

**Ownership and Responsibility**

- **Serverless Architecture:** Cloud providers handle most infrastructure, reducing operational burden on DevOps teams. However, there are new responsibilities related to dependency and cost management.
- **Microservices Architecture:** DevOps teams have greater ownership and responsibility over infrastructure, operations, and performance, which increases operational complexity but also provides more control.
