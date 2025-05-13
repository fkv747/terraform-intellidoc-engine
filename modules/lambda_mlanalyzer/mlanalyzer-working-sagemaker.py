import boto3
import json

def lambda_handler(event, context):
    text_input = event.get("text", "")

    if not text_input:
        return {
            "statusCode": 400,
            "body": json.dumps("No input provided.")
        }

    runtime = boto3.client("sagemaker-runtime")
    response = runtime.invoke_endpoint(
        EndpointName="hf-tc-distilbert-base-uncased-2025-05-12-06-40-41-983",
        ContentType="application/x-text",
        Body=text_input.encode("utf-8")
    )

    result = json.loads(response["Body"].read().decode())
    print("Raw model result:", result)

    probs = result["probabilities"]
    label_map = {
        0: "Cardiology",
        1: "Neurology"
    }

    predicted_index = probs.index(max(probs))
    predicted_category = label_map.get(predicted_index, "Unknown")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "category": predicted_category,
            "probabilities": probs
        })
    }
