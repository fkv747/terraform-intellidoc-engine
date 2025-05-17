# IntelliDoc Engine — Serverless Document Processor with Textract, SageMaker, and OpenSearch on AWS

![IaC](https://img.shields.io/badge/IaC-TERRAFORM-7B42BC?style=for-the-badge&logo=terraform)
![Cloud](https://img.shields.io/badge/CLOUD-AWS-232F3E?style=for-the-badge&logo=amazonaws)
![AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-SERVERLESS-F58536?style=for-the-badge&logo=awslambda)
![Amazon Textract](https://img.shields.io/badge/Amazon%20Textract-DOCUMENT%20TEXT-FF9900?style=for-the-badge&logo=amazonaws)
![Amazon SageMaker](https://img.shields.io/badge/SageMaker-REAL--TIME%20INFERENCE-1A6FFF?style=for-the-badge&logo=amazonaws)
![OpenSearch](https://img.shields.io/badge/OpenSearch-SEARCH%20RESULTS-005EB8?style=for-the-badge&logo=opensearch)
![SNS](https://img.shields.io/badge/SNS-EVENT%20TRIGGER-DD3464?style=for-the-badge&logo=amazonaws)
![DynamoDB](https://img.shields.io/badge/DynamoDB-STORAGE-4053D6?style=for-the-badge&logo=amazonaws)
![API Gateway](https://img.shields.io/badge/API%20Gateway-HTTP%20API-4B5563?style=for-the-badge&logo=amazonaws)

This is a fully serverless document analysis pipeline built on AWS. Users can upload any document (PDF, DOCX, TXT, etc.) via a frontend web app. The pipeline extracts text using **Amazon Textract**, analyzes it in real-time using **SageMaker (DistilBERT)**, and stores the results in **DynamoDB** and **OpenSearch** for instant search and filtering.

The frontend is hosted on **AWS Amplify** with a custom domain via **Route 53**. The backend is deployed entirely via **Terraform**.

---

## Demo

**Watch the full demo on YouTube**  
[Watch the YouTube demo](https://www.youtube.com/watch?v=REPLACE_WITH_YOUR_LINK)

---

## Architecture

![Architecture](./screenshots/intellidoc-engine-diagram.png)

---

## UI

**Upload + Search UI**  
![UI](./screenshots/Front-End.png)

**Search Results**  
![Results](./screenshots/Front-End-2.png)

---

## How It Works

1. **User** uploads a file via the Amplify frontend  
   ![S3 Upload](./screenshots/14-Pipeline-S3-Test.png)
2. File is stored in S3 and **TextractProcessor Lambda** is triggered  
   ![Textract Log](./screenshots/14-Pipeline-CW-Textract-Test.png)
3. Textract extracts raw text and **SNS** sends event to `MLAnalyzer`  
   ![MLAnalyzer Log](./screenshots/14-Pipeline-CW-MLAnalyzer-Test.png)
4. `MLAnalyzer` calls **SageMaker** endpoint (DistilBERT)  
   ![SageMaker Output](./screenshots/Lambda-Sagemaker-Test.png)
5. `MLAnalyzer` invokes `SaveAndIndex` Lambda  
   ![Save Index Log](./screenshots/14-Pipeline-CW-SaveAndIndex-Test.png)
6. `SaveAndIndex` writes metadata to **DynamoDB**  
   ![DynamoDB Entry](./screenshots/14-Pipeline-DynamoDB-Test.png)
7. Extracted insights are indexed into **OpenSearch**  
   ![OpenSearch Final](./screenshots/13-OpenSearch-Deployed.png)

---

## Deployment with Terraform

```bash
git clone https://github.com/fkv747/terraform-intellidoc-engine.git
cd terraform
terraform init
terraform apply
```

---

## Services Used

| Layer        | Service                           |
|--------------|------------------------------------|
| Frontend     | AWS Amplify + Route 53             |
| Upload       | S3 + Presigned URL via Lambda      |
| Extraction   | Amazon Textract                    |
| AI Inference | SageMaker Real-Time (DistilBERT)   |
| Storage      | DynamoDB                           |
| Search       | OpenSearch                         |
| Event Flow   | SNS + Lambda                       |
| API          | API Gateway (HTTP)                 |
| IaC          | Terraform (backend infrastructure) |

---

## DynamoDB Table

**Table Name:** `IntelliDocMetadata`  
**Partition Key:** `DocumentId` (String)

---

## 🔧 Future Enhancements

- Add document previews to search results  
- Enable advanced filtering in OpenSearch  
- Add session-based search tracking

---

## Connect with Me

📫 [LinkedIn](https://www.linkedin.com/in/franc-kevin-v-07108b111/)
