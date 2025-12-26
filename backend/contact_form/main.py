import json
import boto3
import os
import uuid
from datetime import datetime

# Initialize Clients
dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses') # <--- NEW CLIENT

TABLE_NAME = os.environ['DYNAMODB_TABLE']
SENDER_EMAIL = os.environ['SENDER_EMAIL'] # <--- NEW ENV VAR
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    print("Received event:", json.dumps(event))
    headers = {"Content-Type": "application/json"}

    try:
        # Validate Body
        if 'body' not in event or event['body'] is None:
            raise ValueError("No body provided")
            
        if isinstance(event['body'], str):
            body = json.loads(event['body'])
        else:
            body = event['body']
        
        # Prepare Data
        item_id = str(uuid.uuid4())
        name = body.get('name', 'Anonymous')
        email = body.get('email', 'No Email')
        message = body.get('message', 'No Message')
        
        item = {
            'id': item_id,
            'name': name,
            'email': email,
            'message': message,
            'created_at': datetime.utcnow().isoformat()
        }

        # 1. Save to DynamoDB
        table.put_item(Item=item)

        # 2. Send Email Notification (NEW)
        # We wrap this in a try/except so if email fails, the user still gets a success response
        try:
            ses.send_email(
                Source=SENDER_EMAIL,
                Destination={'ToAddresses': [SENDER_EMAIL]}, # Send to yourself
                Message={
                    'Subject': {'Data': f"Portfolio Contact: {name}"},
                    'Body': {
                        'Text': {'Data': f"You received a new message!\n\nName: {name}\nEmail: {email}\n\nMessage:\n{message}"}
                    }
                }
            )
            print("Email sent successfully")
        except Exception as email_error:
            print(f"Failed to send email: {str(email_error)}")
            # We do NOT raise here, because the data is safe in DB.

        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps({"message": "Message sent successfully!", "id": item_id})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": str(e)})
        }