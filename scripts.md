# Script to create a dynamodb table
aws dynamodb create-table  --table-name mi-tabla-dynamodb   
--attribute-definitions AttributeName=LockID,AttributeType=S   
--key-schema AttributeName=LockID,KeyType=HASH   
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Script to list dynamodb tables per region

aws dynamodb list-tables --region us-east-1
