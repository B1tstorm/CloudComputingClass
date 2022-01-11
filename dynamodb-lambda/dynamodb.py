import boto3
import os
import sys
import uuid
import json
from urllib.parse import unquote_plus
from DynamoDbClass import DynamoDbClass

s3_client = boto3.client('s3')


def lambda_handler(event, context):
    # Abholen der JSON Datei
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        fileName = unquote_plus(record['s3']['object']['key'])
        result = s3_client.get_object(Bucket=bucket, Key=fileName) 
        text = result["Body"].read()
        jsonDict = json.loads(text)
      
    # In DynamoDB Tabelle schreiben  
    db = DynamoDbClass('users')
    db.create_item(jsonDict)
    
    


