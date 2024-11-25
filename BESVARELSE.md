# BESVARELSE.md

## Candidate No.: 86

### OPPGAVE 1

#### OPPGAVE 1A

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



#### OPPGAVE 1B 

GitHub Actions Workflow

Link to a working GitHub Actions workflow which has deployed the SAM application to AWS: 

`https://github.com/EfremMic/DevOps_eksamen2024/actions/runs/12019758339/job/33507011553`



### OPPGAVE 2

#### OPPGAVE 2B

**GitHub Actions workflow - main branch**

`https://github.com/EfremMic/DevOps_eksamen2024/actions/runs/12019948725`

**GitHub Actions workflow - feature/test-plan branch**

`https://github.com/EfremMic/DevOps_eksamen2024/actions/runs/11954250011`

**SQS Queue URL**

`https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-candidate-86`

**SQS Sending & Receiving Test**




**Sending a message to the queue**

  ```sh
  aws sqs send-message \
      --queue-url https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-candidate-86 \
      --message-body "Test message to verify without consumer" \
      --region eu-west-1
  ```

  ```json
  {
      "MD5OfMessageBody": "1456f6f0841c7a48e39961c3020d4b66",
      "MessageId": "e51352fe-f42d-449c-aaf4-35ac40847849"
  }
  ```

- **Receiving the message**

  ```sh
  aws sqs receive-message \
      --queue-url https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-candidate-86 \
      --region eu-west-1
  ```

  For testing purposes, I had to add `--attributes VisibilityTimeout=3` to receive the message before it is consumed.



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

Replace `ACCOUNT_ID` with my ID 

**Terraform State File**
Can be found in `pgr301-2024-terraform-state/86`.





### OPPGAVE 3
#### OPPGAVE 3B

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
#### OPPGAVE 4A

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


### OPPGAVE 5

Implementing a system based on serverless architecture with messaging queues like Amazon SQS and Function-as-a-Service(Faas) like AWS Lambda compared to a microservices- based architecture has a very meaningful effects for DevOps principles and practices. 
In the following part I will discuss and evaluate based on the given aspects :


#### 1, Automation and Continuous Delivery (CI/CD)**

Integration CI/CD in serverless architecture and microservice -based architecture has both advantages and disadvantages. 
To start with the advantages of CI/CD – pipelines for serverless architecture: this approach provides a way to deploy individual functions, which gives a better control over small units that are being deployed. This reduces the risk of deployment and through automation tools such as AWS SAM and Terraform, developers can manage changes in function level. Nevertheless, Serverless Architecture makes it possible for developers to deploy their functions rapidly  without requiring direct infrastructure management. However, as production growth and more dependencies are being implemented into the functions, deployment and testing in the CI/CD- pipeline becomes complicated- especially if there are several interdependencies among functions.
When it comes to Microservices : The fact that Microservices operates independently (mostly in a docker- container), it provides isolation and managing CI/CD-pipelines in many cases is easier and strategies for deployment that involve parallel and/or gradual rollout environments can be applied effectively at the service-level. When it comes to the disadvantage; the most common ones are related to managing networking and clusters that often lead automation complexity. To ensure consistency the infrastructure requires explicit management. Another disadvantage of CI/CD in a microservice architecture is connected to higher deployment risks. This means that in some cases developers might have the need to update the entire service when deploying a new state/versions. CI/CD can become challenging, especially if one microservice is dependable on another service, that might require changes in the other service which can increase the risk of integration and worst-case scenario -down time. We can also mention the complexity of Rollbacks to previous state can become painful if several services in the project have been updated simultaneously due to inconsistent state.


#### 2, Observability

When transitioning from microservices architecture to serverless architecture we can experience changes regarding observability, debugging and logging. Serverless architecture in general simplifies deployment, by allowing developers to gain insight into each function and their execution through native tools like AWS, CloudWatch Log and Metrics. These tools are very powerful and provide real-time monitoring of performance , debugging and troubleshooting , as well as allowing developers to manage and use alerts for optimizing system reliability. However , there are challenges to Observability in Faas because serverless systems are ephemeral and are inherently distributed by nature, which makes it difficult to offer end-to-end visibility. Since serverless functions have a short life span and only run when triggered by events, this makes debugging and identifying root cause difficult and challenging. To solve that problem, developers have to integrate/ use additional tools such as AWS-X-Ray, which allows developers to trace and track bugs and monitor applications.

#### 3, Scalability and Cost Control**

Adopting serverless architecture such as AWS Lambda, Amazon SQS compared to a microservices-based offers consequences for resource utilization, scalability and cost optimization. 
The advantage of Serverless architecture is that it offers automatic scaling , cost efficiency – as charges only incur for the compute time consumed and resource utilization – as serverless functions are designed to be stateless, which make serverless architecture ideal for several applications with variable workload. However, since serverless architectures are ephemeral in nature, monitoring and debugging becomes an issue. Nevertheless, they can also face latency problems due to cold starts.
On the other hand, Microservices architectures offers possibilities for independent scaling of services, offering control over performance optimization and resource allocation. However, as much as it sounds simple and practical, it is not always easy. The reason is that – to achieve this flexibility, complex infrastructures are needed and that can potentially  increase resource overhead. It could become very costly if we have many microservices in our project and they all require a runtime environment of their own. 


#### 4, Ownership and Responsibility**

When we move from microservices to serverless setup, the ownership and responsibility of the DevOps team face significant challenges and undergo changes. Here is why: In serverless architecture, cloud provider manages most of the infrastructures – We can mention this as an advantage since it helps to reduce the operational burden of the DevOps team and offers the team more time to focus on application-level responsibilities and less time on scaling, maintenance etc. 
However, this shift comes with new obstacles such as debugging issues and challenges in performance consistency due to the ephemeral and stateless nature of serverless functions. In addition, the followings responsibilities will be introduced to the DevOps team: Dependency Responsibility- managing and making sure of the right dependencies for the project  & Cost Responsibility – making sure & monitoring execution frequence as well as runtime to avoid unnecessary or unexpected cost. 
When we talk about microservice regarding ownership and responsibility, in microservice architecture DevOps team have a greater responsibility and ownership over infrastructure responsibilities, Operational responsibilities and Performance Responsibility. 
Every microservice can have its own lifecycle which means that one must apply strict use of version control, deployment procedures and monitoring solutions which ensures greater flexibility and control. 
However, this much ownership means also more operational complexity and higher cost for maintaining the system. 
