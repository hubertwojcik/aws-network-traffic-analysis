locals {
    name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_guardduty_detector" "this" {
    enable = true

    tags = merge(var.common_tags,{
        Name = "${local.name_prefix}-guardduty"
    })
}



data "aws_iam_policy_document" "lambda_assume" {
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
    }
}

resource "aws_iam_role" "ir_lambda" {
    name = "${local.name_prefix}-ir-lambda-role"
    assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-ir-lambda-role"
    })
}


data "aws_iam_policy_document" "ir_lambda_policy" {
    statement {
      sid = "CloudWatchLogs"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = ["*"]
    }

    statement {
      sid = "DescribeEC2"
      actions = [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeVolumes"
      ]
      resources = ["*"]
    }

    statement {
      sid = "Quarantine"
      actions = [
        "ec2:ModifyInstanceAttribute"
      ]
      resources = ["*"]
    }

    statement {
      sid = "Snapshots"
      actions = [
        "ec2:CreateSnapshot",
        "ec2:CreateTags"
      ]
      resources = ["*"]
    }
}

resource "aws_iam_role_policy" "ir_lambda_inline" {
    name = "${local.name_prefix}-ir-lambda-inline"
    role = aws_iam_role.ir_lambda.id
    policy = data.aws_iam_policy_document.ir_lambda_policy.json
}

data "archive_file" "lambda_zip" {
    type = "zip"
    source_dir = "${path.module}/lambda"
    output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "ir" {
  function_name = "${local.name_prefix}-ir-playbook"
  role = aws_iam_role.ir_lambda.arn
  handler = "index.handler"
  runtime = "python3.12"

  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 30

  environment {
    variables = {
      QUARANTINE_SG_ID = var.quarantine_sg_id
      VICTIM_TAG_KEY   = var.victim_tag_key
      VICTIM_TAG_VALUE = var.victim_tag_value
      REGION       = var.aws_region
    }
  }

  tags = merge(var.common_tags,{
    Name= "${local.name_prefix}-ir-lambda"
  })
}


resource "aws_cloudwatch_log_group" "ir" {
    name = "/aws/lambda/${aws_lambda_function.ir.function_name}"
    retention_in_days = 7

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-ir-lambda-logs"
    })
}


resource "aws_cloudwatch_event_rule" "guardduty_findings" {
    name = "${local.name_prefix}-guardduty-findings"
    description = "Trigger IR lambda on GuardDuty findings"

    event_pattern = jsonencode({
        "source": ["aws.guardduty"],
        "detail_type": ["GuardDuty Finding"]
    })

    tags = merge(var.common_tags,{
        Name = "${local.name_prefix}-eventbridge-guardduty"
    })
}

resource "aws_cloudwatch_event_target" "to_lambda" {
    rule = aws_cloudwatch_event_rule.guardduty_findings.name
    target_id = "IRLambda"
    arn = aws_lambda_function.ir.arn
} 

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ir.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_findings.arn
}