import json
import boto3
import os
import uuid

# DynamoDB client
dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE")
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    http_method = event.get("httpMethod")

    if http_method == "POST":
        # Add a new item
        try:
            body = json.loads(event.get("body", "{}"))
            item_id = str(uuid.uuid4())
            item = {
                "id": item_id,
                "name": body.get("name", ""),
                "description": body.get("description", "")
            }
            table.put_item(Item=item)
            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Item created successfully", "id": item_id})
            }
        except Exception as e:
            return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

    elif http_method == "GET":
        # Fetch all items or a single item by query parameter
        try:
            params = event.get("queryStringParameters") or {}
            item_id = params.get("id")

            if item_id:
                response = table.get_item(Key={"id": item_id})
                item = response.get("Item")
                if not item:
                    return {"statusCode": 404, "body": json.dumps({"error": "Item not found"})}
                return {"statusCode": 200, "body": json.dumps(item)}
            else:
                # Scan table for all items
                response = table.scan()
                items = response.get("Items", [])
                return {"statusCode": 200, "body": json.dumps(items)}
        except Exception as e:
            return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

    else:
        return {"statusCode": 400, "body": json.dumps({"error": "Unsupported HTTP method"})}
