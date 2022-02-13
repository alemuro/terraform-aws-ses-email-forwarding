variable "prefix" {
  default     = "email-forward"
  description = "All resources will be tagged using this prefix name"
}

variable "s3_bucket" {
  type        = string
  description = "Bucket where emails will be stored"
}

variable "s3_bucket_prefix" {
  type        = string
  description = "Path inside the bucket where emails will be stored"
}

variable "mail_sender" {
  type        = string
  description = "Email(s) used to send messages from (when forwarding)"
}

variable "mail_targets" {
  type        = list(string)
  description = "Email addresses that can be sent to"
}

variable "mail_recipient" {
  type        = string
  description = "Email used to send messages to (when forwarding)"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region where we should configure the integration"
}

variable "domain" {
  type        = string
  description = "Domain to configure (ex: aleix.cloud)"
}

variable "dns_provider" {
  type        = string
  default     = "aws"
  description = "DNS provider where the domain is registered."
}

