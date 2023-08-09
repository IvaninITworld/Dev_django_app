# Use this code snippet in your app.
# If you need more information about configurations
# or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developer/language/python/
import json

import boto3
from botocore.exceptions import ClientError


# secret_name 을 str 형태로 받아버리면 ?
def get_secret(secret_name:str) -> dict:

    # secret_name = "like/lion/lecture"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']

    print("secret: ", secret)
    print("type of secret: ", type(secret))

    print("secret: ", json.loads(secret))
    print("type of secret: ", type(json.loads(secret)))

    # Your code goes here.
    return json.loads(secret)