import json
import boto3
import uuid
from datetime import datetime
import botocore.auth
import botocore.awsrequest
import botocore.session
from urllib.request import Request, urlopen

dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    print("📥 SaveAndIndex triggered")

    payload = json.loads(event['body'])
    document_id = str(uuid.uuid4())

    # Save to DynamoDB
    item = {
        "DocumentId": {"S": document_id},
        "TextLines": {"S": json.dumps(payload.get("lines", []))},
        "Insights": {"S": json.dumps(payload.get("insights", {}))}
    }

    print(f"🗂️ Saving to DynamoDB: {item}")
    dynamodb.put_item(
        TableName="IntelliDocMetadata",
        Item=item
    )

    # Signed OpenSearch indexing
    region = "us-east-1"
    service = "es"
    host = "search-intellidoc-engine-2cefx5uy2eedt6kxs23a5f2cs4.us-east-1.es.amazonaws.com"
    endpoint = f"https://{host}/intellidoc/_doc/{document_id}"

    document_to_index = {
        "document_id": document_id,
        "summary": payload.get("insights", {}).get("summary"),
        "entities": payload.get("insights", {}).get("entities"),
        "timestamp": datetime.now().isoformat()
    }

    session = botocore.session.get_session()
    credentials = session.get_credentials()
    request = botocore.awsrequest.AWSRequest(
        method="PUT",
        url=endpoint,
        data=json.dumps(document_to_index).encode("utf-8"),
        headers={"Host": host, "Content-Type": "application/json"}
    )
    signer = botocore.auth.SigV4Auth(credentials, service, region)
    signer.add_auth(request)

    signed_request = request.prepare()
    req = Request(
        signed_request.url,
        data=signed_request.body,
        headers=dict(signed_request.headers),
        method="PUT"
    )

    try:
        with urlopen(req) as response:
            print("📤 OpenSearch response:", response.status, response.read().decode())
    except Exception as e:
        print("❌ OpenSearch error:", str(e))

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Data saved and indexed", "DocumentId": document_id})
    }