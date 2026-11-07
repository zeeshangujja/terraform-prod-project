


# ---------- 2. Lambda permissions ----------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "ecs-alert-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "lambda" {
  name = "ecs-alert-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:FilterLogEvents"]
        Resource = "${var.log_group_arn}:*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = var.sns_topic_arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

# ---------- 3. Lambda function ----------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "alert" {
  function_name    = "ecs-alert"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      LOG_GROUP     = var.log_group_name
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

# ---------- 4. EventBridge: 3 rules, all call the same Lambda ----------
locals {
  rules = {
    task-state = {
      source      = ["aws.ecs"]
      detail-type = ["ECS Task State Change"]
      detail = {
        clusterArn = [var.cluster_arn]
        lastStatus = ["RUNNING", "STOPPED"]
      }
    }

    image-push = {
      source      = ["aws.ecr"]
      detail-type = ["ECR Image Action"]
      detail = {
        action-type     = ["PUSH"]
        result          = ["SUCCESS"]
        repository-name = [var.ecr_repository_name]
      }
    }

    deployment = {
      source      = ["aws.ecs"]
      detail-type = ["ECS Deployment State Change"]
      detail = {
        eventName = [
          "SERVICE_DEPLOYMENT_IN_PROGRESS",
          "SERVICE_DEPLOYMENT_COMPLETED",
          "SERVICE_DEPLOYMENT_FAILED"
        ]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = local.rules

  name = "ecs-alert-${each.key}"
  event_pattern = jsonencode({
    source        = each.value.source
    "detail-type" = each.value["detail-type"]
    detail        = each.value.detail
  })
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = local.rules

  rule = aws_cloudwatch_event_rule.this[each.key].name
  arn  = aws_lambda_function.alert.arn
}

resource "aws_lambda_permission" "this" {
  for_each = local.rules

  statement_id  = "AllowEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[each.key].arn
}