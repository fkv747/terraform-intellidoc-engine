import boto3
import json
import os

textract = boto3.client('textract')

def lambda_handler(event, context):
    print("🧪 ENV CHECK:", dict(os.environ))
    
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    textract_role_arn = os.environ['TEXTRACT_ROLE_ARN']

    response = textract.start_document_text_detection(
    DocumentLocation={
        'S3Object': {
            'Bucket': bucket,
            'Name': key
        }
    },
    NotificationChannel={
        'RoleArn': 'arn:aws:iam::245994248859:role/TextractJobResults_publisher_role',
        'SNSTopicArn': 'arn:aws:sns:us-east-1:245994248859:TextractJobResults'
    }
)


    print(f"✅ Textract job started: {response['JobId']}")


    print(f"📝 New file uploaded: {key}")
    print(f"📦 Bucket: {bucket}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'TextractProcessor ran successfully',
            'bucket': bucket,
            'key': key
        })
    }
