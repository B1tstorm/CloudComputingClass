import boto3
import os
import sys
import uuid
import json
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')


def lambda_handler(event, context):
  for record in event['Records']:
      bucket = record['s3']['bucket']['name']
      fileName = unquote_plus(record['s3']['object']['key'])
      tempFileName = fileName.replace('/', '')
      #ein unique dateiname wird erstellt in dem ordener temp (in der lambda)
      file_local_path = '/tmp/{}{}'.format(uuid.uuid4(), tempFileName)
      upload_file_name = '{}{}'.format(uuid.uuid4(), tempFileName)
      s3_client.download_file(bucket, fileName, file_local_path)
      s3_client.upload_file(file_local_path,"lab6-project-s3-target", upload_file_name)
       
      
      
