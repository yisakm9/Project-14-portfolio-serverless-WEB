import json
import boto3
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    print("Received event:", json.dumps(event)) # This log helps us debug

    # Standard headers for HTTP API
    headers = {
        "Content-Type": "application/json"
    }

    try:
        # Robust Body Parsing
        if 'body' not in event or event['body'] is None:
            raise ValueError("No body provided")
            
        # Handle cases where body is already a dict (local testing) vs string (API GW)
        if isinstance(event['body'], str):
            body = json.loads(event['body'])
        else:
            body = event['body']
        
        # Create Item
        item = {
            'id': str(uuid.uuid4()),
            'name': body.get('name'),
            'email': body.get('email'),
            'message': body.get('message'),
            'created_at': datetime.utcnow().isoformat()
        }

        # Save to DynamoDB
        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps({"message": "Message sent successfully!", "id": item['id']})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": str(e)})
        }