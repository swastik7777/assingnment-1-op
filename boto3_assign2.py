"""Tasks 1️ 
AWS EC2 Management with Python (Boto3) 

Write a Python script to: 

Launch an EC2 instance (if not already running). 

Retrieve instance details (public IP, instance state, uptime). 

Stop the instance if not needed (e.g., based on a condition like time of day). 

"""


import boto3
import logging
from logging.handlers import RotatingFileHandler
import boto3.session

# Set up logging with rotation
log_filename = "ec2_actions.log"
logger = logging.getLogger("EC2Logger")
logger.setLevel(logging.INFO)

# Create a rotating file handler (log file size will be 1MB, backup 3 log files)
handler = RotatingFileHandler(log_filename, maxBytes=1e6, backupCount=3)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

logger.addHandler(handler)


running_instance_id=[]

aws_management_console = boto3.session.Session(profile_name="default")

ec2_console = aws_management_console.client(service_name="ec2",region_name="us-east-1")
cloudwatch=aws_management_console.client(service_name="cloudwatch",region_name="us-east-1")
response = ec2_console.describe_instances(
    Filters=[
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]
)

for instance in response["Reservations"]:
    for each in instance["Instances"]:
        ids=running_instance_id.append(each["InstanceId"])
        # Retrieve instance details (public IP, instance state, uptime).
        public_ip=each.get("PublicIpAddress")
        instance_st=each["State"]["Name"]
        up_time=each["LaunchTime"]
        

if ids not in  running_instance_id:
    logger.warning("No running instances found. Launching a new instance.")
    run_instance=ec2_console.run_instances(
        ImageId='ami-084568db4383264d4',
        InstanceType="t2.micro",
        MaxCount=1,
        MinCount=1
        )
# CloudWatch Alarms for CPU and Disk Usage
for instance_id in running_instance_id:
    # CPU Utilization Alarm
        cloudwatch.put_metric_alarm(
        AlarmName=f"HighCPUUtilization-{instance_id}",
        MetricName="CPUUtilization",
        Namespace="AWS/EC2",
        Statistic="Average",
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            }
        ],
        Period=300,
        EvaluationPeriods=1,
        Threshold=80.0,
        ComparisonOperator="GreaterThanOrEqualToThreshold",
        AlarmActions=["arn:aws:sns:us-east-1:920268369058:HighCPUUtilization"],  # Replace with your SNS topic ARN to send notifications
        OKActions=["arn:aws:sns:us-east-1:920268369058:HighCPUUtilization"],     # Replace with your SNS topic ARN to send notifications
        InsufficientDataActions=["arn:aws:sns:us-east-1:920268369058:HighCPUUtilization"],  # Replace with your SNS topic ARN to send notifications
        Unit="Percent"
    )
    
    # Disk Space Utilization Alarm
        cloudwatch.put_metric_alarm(
        AlarmName=f"HighDiskSpaceUtilization-{instance_id}",
        MetricName="DiskSpaceUtilization",
        Namespace="AWS/EC2",
        Statistic="Average",
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            }
        ],
        Period=300,
        EvaluationPeriods=1,
        Threshold=80.0,  # 80% disk usage threshold
        ComparisonOperator="GreaterThanOrEqualToThreshold",
        AlarmActions=["arn:aws:sns:us-east-1:920268369058:diskspaceutilization"],  # Replace with your SNS topic ARN to send notifications
        OKActions=["arn:aws:sns:us-east-1:920268369058:diskspaceutilization"],     # Replace with your SNS topic ARN to send notifications
        InsufficientDataActions=["arn:aws:sns:us-east-1:920268369058:diskspaceutilization"],  # Replace with your SNS topic ARN to send notifications
        Unit="Percent"
    )
        
        logger.info(f"Instance started: {each['InstanceId']} | Public IP: {public_ip} | State: {instance_st} | Uptime: {up_time}")
        logger.info(f"CloudWatch alarms set for CPU and Disk usage on instance {instance_id}")


