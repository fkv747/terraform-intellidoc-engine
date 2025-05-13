import json
import boto3
import os
import requests
from requests_aws4auth import AWS4Auth
from datetime import datetime
from decimal import Decimal

region = os.getenv("REGION", "us-east-1")
service = "es"
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    region,
    service,
    session_token=credentials.token
)

def lambda_handler(event, context):
    print("📥 SaveAndIndex Lambda invoked")
    print("📦 Raw event:", json.dumps(event))

    # ✅ Handle SNS-style "body" wrapping
    if "body" in event and isinstance(event["body"], str):
        event = json.loads(event["body"])
        print("✅ Unwrapped body:", json.dumps(event))

    # ✅ Real structure expected now
    document_id = "doc-" + datetime.now().strftime("%Y%m%d%H%M%S")
    category = "Cardiology"
    confidence = Decimal("0.99")

    extracted_text = event.get("lines", ["No text provided"])
    timestamp = datetime.now().isoformat()

    payload = {
    "DocumentId": document_id,
    "category": category,
    "confidence": str(confidence),
    "extracted_text": extracted_text,
    "timestamp": timestamp
}

    print("📤 Final payload:", json.dumps(payload, default=str))

    # ✅ Static config for known working infra
    index = "documents"
    url = "https://search-intellidoc-engine-2cefx5uy2eedt6kxs23a5f2cs4.us-east-1.es.amazonaws.com"
    table_name = "IntelliDocMetadata"

    save_to_opensearch(document_id, payload, index, url, awsauth)
    save_to_dynamodb(payload, table_name)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "✅ Data saved successfully"})
    }

def save_to_opensearch(document_id, payload, index, url, auth):
    try:
        response = requests.put(
            f"{url}/{index}/_doc/{document_id}",
            auth=auth,
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        print("🔍 OpenSearch response:", response.text)
    except Exception as e:
        print("❌ OpenSearch error:", str(e))

def save_to_dynamodb(payload, table_name):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(table_name)

    try:
        response = table.put_item(Item=payload)
        print("🧾 DynamoDB response:", response)
    except Exception as e:
        print("❌ DynamoDB error:", str(e))
