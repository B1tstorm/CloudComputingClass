import boto3

# Tutorial: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html

class DynamoDbClass:    
    def __init__(self, table_name):
        self.table_name = table_name
        self.client = boto3.client('dynamodb')
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(self.table_name)
        response = self.client.list_tables()
        print(response['TableNames'])
    
             
    def get_tables(self):
        response = self.client.list_tables()
        print(response['TableNames'])
        
        
    def create_item(self, jsonFile):
        print(self.table.creation_date_time)
        self.table.put_item(Item= jsonFile)
        
        
    def get_item(self):
        print(self.table.creation_date_time)
        response = self.table.get_item(
            Key={
                'username': 'janedoe',
                'last_name': 'Doe'
            }
        )
        item = response['Item']
        print(item)
        