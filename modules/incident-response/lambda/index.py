import json




def handler(event, context):
    """
    Bolierplate handler
    """
    
    print("Received event:", json.dumps(event))



    return {
        "statusCode": 200,
        "body": json.dumps({"message": ""}),
    }
