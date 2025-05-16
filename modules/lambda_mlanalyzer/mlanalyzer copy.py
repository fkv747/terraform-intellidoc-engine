import boto3
import json

lambda_client = boto3.client('lambda')
textract = boto3.client('textract')

def call_sagemaker_model(text):
    runtime = boto3.client("sagemaker-runtime")
    response = runtime.invoke_endpoint(
        EndpointName="hf-tc-distilbert-base-uncased-2025-05-16-11-42-58-102",
        ContentType="application/x-text",
        Body=text.encode("utf-8")
    )

    result = json.loads(response["Body"].read().decode())
    probs = result["probabilities"]

    topics = ["aws", "automation"]  # Or anything you want to tag
    confidence = max(probs)
    sentiment = "positive" if confidence >= 0.5 else "negative"

    return {
        "insights": {
            "sentiment": sentiment,
            "confidence": round(confidence, 2),
            "topics": topics
        }
    }

def lambda_handler(event, context):
    print("📬 MLAnalyzer triggered by SNS")

    sns_record = event['Records'][0]['Sns']
    message = json.loads(sns_record['Message'])

    job_id = message.get("JobId")
    print(f"🔍 Fetching Textract results for JobId: {job_id}")

    response = textract.get_document_text_detection(JobId=job_id)
    blocks = response.get("Blocks", [])
    text_lines = [block["Text"] for block in blocks if block["BlockType"] == "LINE"]

    print(f"📝 Extracted {len(text_lines)} lines:")
    for line in text_lines:
        print("•", line)

    joined_text = " ".join(text_lines)
    insights = call_sagemaker_model(joined_text)
    print("📊 SageMaker Insights:", json.dumps(insights))

    payload = {
    "lines": text_lines,
    "insights": insights["insights"]
    }

    response = lambda_client.invoke(
    FunctionName="SaveAndIndex",
    InvocationType="Event",
    Payload=json.dumps({ "body": json.dumps(payload) })
    )

    print("📬 Invoked SaveAndIndex Lambda:", response['StatusCode'])

    return {
    'statusCode': 200,
    'body': json.dumps({
        'linesExtracted': len(text_lines),
        'insights': insights
    })
    }