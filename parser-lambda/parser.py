import boto3
import os
import sys
import uuid
import json
from urllib.parse import unquote_plus
import pandas as pd # solution -> https://korniichuk.medium.com/lambda-with-pandas-fd81aa2ff25e

s3_client = boto3.client('s3')


def lambda_handler(event, context):
  for record in event['Records']:
      bucket = record['s3']['bucket']['name']
      fileName = unquote_plus(record['s3']['object']['key'])
      tempFileName = fileName.replace('/', '')
      #ein unique dateiname wird erstellt in dem ordener temp (in der lambda)
      file_local_path = '/tmp/{}{}'.format(uuid.uuid4(), tempFileName)
      upload_path = 'csv/'
      #upload_file_name = '{}{}'.format(uuid.uuid4(), tempFileName)
      s3_client.download_file(bucket, fileName, file_local_path)
      convert_to_flat_csv(file_local_path)
      
      s3_client.upload_file("test.csv", "lab6-project-s3", upload_path + "test.csv")
      #s3_client.upload_file(file_local_path,"lab6-project-s3", upload_path + upload_file_name)

      #call the db-writer-lambda
      boto3.client('lambda').invoke(FunctionName="db-writer-lambda",InvocationType='Event',Payload=json.dumps(event))
      
      
def convert_to_flat_csv(file_path):
  with open(file_path) as file:
    df = pd.DataFrame(file)
  
  df.to_csv("test.csv", index=False)
  
  #aws lambda update-function-code --function-name parser-lambda --zip-file fileb://my-deployment-package.zip 
  #s3://lab6-project-s3/
  # Endgültig löschen
