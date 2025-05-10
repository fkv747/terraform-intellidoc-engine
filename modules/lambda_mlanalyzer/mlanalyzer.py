import json
import boto3

sagemaker = boto3.client('sagemaker-runtime')

def lambda_handler(event, context):
    print("Event:", event)

    extracted_text = event.get("text", "")

    if not extracted_text:
        return {
            "statusCode": 400,
            "body": json.dumps("No text provided.")
        }

    try:
        # Prepare the payload as a JSON string with 'inputs' key
        payload = json.dumps({"inputs": extracted_text})

        response = sagemaker.invoke_endpoint(
            EndpointName="jumpstart-dft-hf-tc-distilbert-base-20250510-164655",
            ContentType="application/json",  # Set the correct content type
            Body=payload
        )

        result = json.loads(response['Body'].read().decode())

        print("SageMaker response:", json.dumps(result, indent=2))

        return {
            "statusCode": 200,
            "body": json.dumps({
                "classification": result
            })
        }

    except Exception as e:
        print("SageMaker invocation failed:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps("Error invoking SageMaker")
        }
