import json
import boto3
import os
import uuid
from datetime import datetime

# Initialize DynamoDB Client
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    print("Received event:", json.dumps(event))

    # Handle CORS Preflight (Optionally handled by API Gateway, but good safety)
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    try:
        # Parse Request Body
        if 'body' not in event or event['body'] is None:
            raise ValueError("No body provided")
            
        body = json.loads(event['body'])
        
        # Validation
        required_fields = ['name', 'email', 'message']
        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": headers,
                    "body": json.dumps({"error": f"Missing field: {field}"})
                }

        # Create Item
        item = {
            'id': str(uuid.uuid4()),
            'name': body['name'],
            'email': body['email'],
            'message': body['message'],
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
            "body": json.dumps({"error": "Internal Server Error"})
        }