import os
import boto3

logs = boto3.client("logs")
sns = boto3.client("sns")


def send(subject, message):
    sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject=subject[:100],
        Message=message,
    )


def get_logs(task_id):
    try:
        resp = logs.filter_log_events(
            logGroupName=os.environ["LOG_GROUP"],
            logStreamNamePrefix=f"app/app/{task_id}",
            limit=30,
        )
        return "\n".join(e["message"] for e in resp["events"]) or "No logs found"
    except Exception as e:
        return f"Could not read logs: {e}"


def handler(event, context):
    kind = event["detail-type"]
    detail = event["detail"]

    # Container started or stopped
    if kind == "ECS Task State Change":
        task_id = detail["taskArn"].split("/")[-1]
        status = detail["lastStatus"]

        if status == "RUNNING":
            send("ECS: Container STARTED",
                 f"Container started successfully.\nTask ID: {task_id}")

        elif status == "STOPPED":
            reason = detail.get("stoppedReason", "N/A")
            if "health check" in reason.lower():
                subject = "ECS: HEALTH CHECK FAILED"
            else:
                subject = "ECS: Container STOPPED"

            send(subject,
                 f"Task ID: {task_id}\n"
                 f"Reason: {reason}\n\n"
                 f"--- Last logs ---\n{get_logs(task_id)}")

    # New image pushed to ECR
    elif kind == "ECR Image Action":
        send("ECR: New image pushed",
             f"Repository: {detail.get('repository-name')}\n"
             f"Image tag: {detail.get('image-tag')}\n"
             f"Digest: {detail.get('image-digest')}")

    # ECS service deployment
    elif kind == "ECS Deployment State Change":
        send(f"ECS Deployment: {detail.get('eventName')}",
             f"Event: {detail.get('eventName')}\n"
             f"Reason: {detail.get('reason', 'N/A')}\n"
             f"Deployment: {detail.get('deploymentId')}")