import json
import os
import boto3
import requests
from requests_aws4auth import AWS4Auth

region = os.environ["REGION"]
service = "es"
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

opensearch_url = os.environ["OPENSEARCH_URL"]
index_name = os.environ["OPENSEARCH_INDEX"]

def lambda_handler(event, context):
    query = event.get("queryStringParameters", {}).get("q", "")
    print("✅ SearchOpenSearch Lambda invoked")
    print("🔍 Query received:", query)

    if not query:
        return {
            "statusCode": 400,
            "headers": cors_headers(),
            "body": json.dumps({"error": "Missing query parameter `q`"})
        }

    search_body = {
        "query": {
            "multi_match": {
                "query": query,
                "fields": ["category", "extracted_text"]
            }
        }
    }

    try:
        response = requests.get(
            f"{opensearch_url}/{index_name}/_search",
            auth=awsauth,
            headers={"Content-Type": "application/json"},
            json=search_body
        )

        data = response.json()
        hits = data.get("hits", {}).get("hits", [])
        results = [hit["_source"] for hit in hits]
        print("📤 Results returned:", json.dumps(results))

        return {
            "statusCode": 200,
            "headers": cors_headers(),
            "body": json.dumps({"results": results})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": cors_headers(),
            "body": json.dumps({"error": str(e)})
        }

def cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,OPTIONS",
        "Access-Control-Allow-Headers": "*",
        "Content-Type": "application/json"
    }
