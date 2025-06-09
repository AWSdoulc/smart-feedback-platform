import json
import boto3
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def handler(event, context):
    try:
        print("EVENT:", json.dumps(event))

        body = json.loads(event.get("body", "{}"))
        feedback_text = body.get("message", "").strip() 

        if not feedback_text:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Feedback-Text fehlt"})
            }

        feedback_id = str(uuid.uuid4())
        item = {
            "id": feedback_id,
            "timestamp": datetime.utcnow().isoformat(),
            "text": feedback_text,
            "sentiment": "PENDING"
        }

        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Feedback gespeichert", "id": feedback_id})
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal Server Error"})
        }