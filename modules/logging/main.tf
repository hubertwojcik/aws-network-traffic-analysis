data "aws_caller_identity" "current" {}

locals {
    name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_s3_bucket" "flow_logs" {
    bucket = "${local.name_prefix}-flowlogs-${data.aws_caller_identity.current.account_id}"

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-flowlogs"
    })
}


resource "aws_s3_bucket_public_access_block" "flow_logs" {
    bucket = aws_s3_bucket.flow_logs.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "flow_logs" {
    bucket = aws_s3_bucket.flow_logs.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
    bucket = aws_s3_bucket.flow_logs.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
          
    }
}

data "aws_iam_policy_document" "flow_logs_bucket_policy" {
    statement {
      sid = "AWSLogDeliveryWrite"
      principals {
        type = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
      actions = ["s3:PutObject"]
      resources = [
        "${aws_s3_bucket.flow_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      ]
      
      condition {
        test = "StringEquals"
        variable = "s3:x-amz-acl"
        values = ["bucket-owner-full-control"]
      }  
      
    }

    statement {
      sid = "AWSLogDeliveryAclCheck"
      principals {
        type = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
      actions = ["s3:GetBucketAcl"]
      resources = [aws_s3_bucket.flow_logs.arn]
    }
}

resource "aws_s3_bucket_policy" "flow_logs" {
    bucket = aws_s3_bucket.flow_logs.id
    policy = data.aws_iam_policy_document.flow_logs_bucket_policy.json
}

resource "aws_flow_log" "vpc" {
    vpc_id = var.vpc_id
    traffic_type = "ALL"
    log_destination_type = "s3"
    log_destination = aws_s3_bucket.flow_logs.arn
    
    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-vpc-flow-log"
    })

    depends_on = [ aws_s3_bucket.flow_logs ]
}