import boto3

# Tutorial: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html

class DynamoDbClass:    
    def __init__(self, table_name):
        self.table_name = table_name
        # Client to act like cli or console (list tables etc.) https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html#client
        self.client = boto3.client('dynamodb', endpoint_url='http://localhost:8000')
        # Get the service resource to get functionalities like create_table() https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html#service-resource
        self.dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:8000')
        # Funcionalities like CRUD https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html#table
        self.table = self.dynamodb.Table(self.table_name)
    
        
        response = self.client.list_tables()
        print(response['TableNames'])
    
    
    def create_table(self):
        existing_tables = self.client.list_tables()['TableNames']
        for existing_table in existing_tables:
            if existing_table == 'users':
                return
            
        # Create the DynamoDB table.
        table = self.dynamodb.create_table(
            TableName=self.table_name,
            KeySchema=[
                {
                    'AttributeName': 'id',
                    'KeyType': 'S'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'id',
                    'AttributeType': 'S'
                },
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
        )
        # Wait until the table exists.
        table.meta.client.get_waiter('table_exists').wait(TableName=self.table_name)

        # Print out some data about the table.
        print(table.item_count)
        
        
    def get_tables(self):
        response = self.client.list_tables()
        print(response['TableNames'])
        
        
    def create_item(self):
        print(self.table.creation_date_time)
        self.table.put_item(
        Item={
                'username': 'janedoe',
                'first_name': 'Jane',
                'last_name': 'Doe',
                'age': 25,
                'account_type': 'standard_user',
            }
        )
        
        
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
        