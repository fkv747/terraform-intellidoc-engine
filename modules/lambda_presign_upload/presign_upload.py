import json
import boto3
import os
import urllib.parse

s3 = boto3.client('s3')
bucket_name = os.environ['UPLOAD_BUCKET']

def lambda_handler(event, context):
    
    # Handle preflight CORS request
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return {
        "statusCode": 200,
        "headers": cors_headers(),
        "body": json.dumps({"message": "CORS preflight success"})
    }
    
    try:
        # Parse filename from query string or body
        filename = None
        if event.get("queryStringParameters") and "filename" in event["queryStringParameters"]:
            filename = event["queryStringParameters"]["filename"]
        elif event.get("body"):
            body = json.loads(event["body"])
            filename = body.get("filename")

        if not filename:
            return {
                "statusCode": 400,
                "headers": cors_headers(),
                "body": json.dumps({"error": "Missing 'filename'"})
            }

        # URL-encode in case of spaces or special characters
        safe_filename = urllib.parse.quote_plus(filename)

        # Generate presigned URL
        url = s3.generate_presigned_url(
            ClientMethod='put_object',
            Params={
                'Bucket': bucket_name,
                'Key': safe_filename,
                'ContentType': 'application/octet-stream'
            },
            ExpiresIn=300  # 5 mins
        )

        return {
            "statusCode": 200,
            "headers": cors_headers(),
            "body": json.dumps({"upload_url": url})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": cors_headers(),
            "body": json.dumps({"error": str(e)})
        }

def cors_headers():
    return {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST",
        "Access-Control-Allow-Headers": "*"
    }
