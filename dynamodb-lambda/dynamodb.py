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
        #tempFileName = fileName.replace('/', '')
        #ein unique dateiname wird erstellt in dem ordener temp (in der lambda)
        #file_local_path = '/tmp/{}{}'.format(uuid.uuid4(), tempFileName)
        #s3_client.download_file(bucket, fileName, file_local_path)    
        result = s3_client.get_object(Bucket=bucket, Key=fileName) 
        text = result["Body"].read()
        jsonDict = json.loads(text)
        print(text) # Use your desired JSON Key for your value 
      
    # In DynamoDB Tabelle schreiben  
    db = DynamoDbClass('users')
    db.create_table() # prüft selbst ob existiert
    db.create_item(jsonDict)
    #db.get_item()
    #db.get_tables()

#lambda_handler("", "")
