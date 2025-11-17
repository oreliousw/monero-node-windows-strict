import boto3
import sys

TOPIC_ARN = "arn:aws:sns:us-west-2:381328847089:monero-alerts"

subject = sys.argv[1]
message = sys.argv[2]

sns = boto3.client("sns")
sns.publish(
    TopicArn=TOPIC_ARN,
    Subject=subject,
    Message=message
)
