import boto3
import os
import sys
import uuid
import json
from urllib.parse import unquote_plus
import pandas as pd # solution -> https://korniichuk.medium.com/lambda-with-pandas-fd81aa2ff25e

s3_client = boto3.client('s3')


def lambda_handler(event, context):
  print("Python version: {} \nVersion info: {}".format(sys.version, sys.version_info))
  print("OS Platform: {}".format(sys.platform))
  for record in event['Records']:
      bucket = record['s3']['bucket']['name']
      fileName = unquote_plus(record['s3']['object']['key'])
      tempFileName = fileName.replace('/', '')
      #ein unique dateiname wird erstellt in dem ordener temp (in der lambda)
      file_local_path = '/tmp/{}{}'.format(uuid.uuid4(), tempFileName)
      s3_client.download_file(bucket, fileName, file_local_path)
      
      convert_to_flat_csv(file_local_path)
      s3_client.upload_file("/tmp/test.csv", "lab6-project-s3v2", "{}.csv".format(uuid.uuid4()))

      #call the db-writer-lambda
      boto3.client('lambda').invoke(FunctionName="db-writer-lambda",InvocationType='Event',Payload=json.dumps(event))
      
      
def convert_to_flat_csv(file_path):
  print("#####\nfile_path: " + file_path + "\n######")
  with open(file_path) as file:
    print("with Open hat geklappt")
    df = pd.DataFrame(file)
  
  print("with open wurde verlassen")
  df.to_csv("/tmp/test.csv", index=False)
