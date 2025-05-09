import boto3
import json

lambda_client = boto3.client('lambda')
textract = boto3.client('textract')

def call_sagemaker_stub(text_lines):
    print("🧠 [SageMaker Stub] Simulating analysis...")
    # Pretend we ran an ML model and got this result
    return {
        "insights": {
            "sentiment": "positive",
            "confidence": 0.97,
            "topics": ["aws", "automation"]
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

    # Simulate SageMaker
    insights = call_sagemaker_stub(text_lines)
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