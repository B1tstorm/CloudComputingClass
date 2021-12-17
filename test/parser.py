#import boto3

#s3 = boto3.resource('s3')

#def lambda_handler(event, context):
 #   # TODO implement
  #  data = event
   # s3.Bucket('lab6-project-s3-target').put_object(Key='test.json', Body=data)



import boto3
import os
import sys
import uuid
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')


def lambda_handler(event, context):
  for record in event['Records']:
      bucket = record['s3']['bucket']['name']
      key = unquote_plus(record['s3']['object']['key'])
      tmpkey = key.replace('/', '')
      download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
      s3_client.download_file(bucket, key, download_path)
      s3_client.upload_file(download_path,"lab6-project-s3-target", key)