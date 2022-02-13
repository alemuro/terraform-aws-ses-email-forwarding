data "archive_file" "zipit" {
  type        = "zip"
  source_file = local.code_file_path
  output_path = "${local.code_file_path}.zip"
}

/** AWS account id */
data "aws_caller_identity" "current" {}


/** Lambda Components */

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.prefix}-lambda-policy"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3Access",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}/${var.s3_bucket_prefix}/*"
            ]
        },
        {
            "Sid": "SESAccess",
            "Effect": "Allow",
            "Action": [
                "ses:SendRawEmail"
            ],
            "Resource": [
                "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:identity/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_email_fw_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${local.code_file_path}.zip"
  function_name    = "${var.prefix}-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "email-forward.lambda_handler"
  source_code_hash = data.archive_file.zipit.output_base64sha256

  timeout = 30
  runtime = "python3.8"

  environment {
    variables = {
      MailS3Bucket  = var.s3_bucket
      MailS3Prefix  = var.s3_bucket_prefix
      MailSender    = var.mail_sender
      MailRecipient = var.mail_recipient
      Region        = var.aws_region
    }
  }
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id  = "GiveSESPermissionToInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "ses.amazonaws.com"
}


/** SES Components */

resource "aws_ses_receipt_rule_set" "fw_rules" {
  rule_set_name = local.rule_set_name
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = local.rule_set_name
}

resource "aws_ses_receipt_rule" "fw" {
  name          = var.prefix
  rule_set_name = local.rule_set_name
  recipients    = [var.mail_sender]
  enabled       = true
  scan_enabled  = false

  s3_action {
    bucket_name       = var.s3_bucket
    object_key_prefix = "${var.s3_bucket_prefix}/"
    position          = 1
  }

  lambda_action {
    function_arn    = aws_lambda_function.lambda_function.arn
    invocation_type = "Event"
    position        = 2
  }
}

resource "aws_ses_domain_identity" "domain" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.domain.domain
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain = aws_ses_domain_identity.domain.id
}

