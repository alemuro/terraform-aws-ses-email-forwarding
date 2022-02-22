locals {
  code_file_path = "${path.module}/code/email-forward.py"
  rule_set_name  = "${var.prefix}-rules"

  use_aws        = var.dns_provider == "aws" ? true : false
}