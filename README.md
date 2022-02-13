forked from alemuro/terraform-aws-ses-email-forwarding

# Terraform AWS SES Email Forwarding 

This module configures Amazon SES to forward emails to an existing account (gmail or something). This module will configure the following resources:

* SES rule set to save the incoming emails to S3 and to execute a Lambda.
* Lambda that will forward the email from `sender` to `recipient`.
* List of email addresses that can be forwarded to in `email_targets`

This module implements the official solution by AWS: 
https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/
and the code from https://github.com/alemuro/terraform-aws-ses-email-forwarding

The original code didn't work (there was a PR to resolve this https://github.com/alemuro/terraform-aws-ses-email-forwarding/pull/7 )

## Arguments

| Name               | Type   | Required | Default         | Description                                          |
|--------------------|--------|----------|-----------------|------------------------------------------------------|
| `s3_bucket`        | String | Yes      |                 | S3 Bucket where emails will be stored                |
| `s3_bucket_prefix` | String | Yes      |                 | Path inside the bucket where emails will be stored   |
| `mail_targets`     | Liat   | Yes      |                 | Email addresses that can be sent to                  |
| `mail_sender`      | String | Yes      |                 | Email used to send messages from (when forwarding)   |
| `mail_recipient`   | String | Yes      |                 | Email used to send messages to (when forwarding)     |
| `domain`           | String | Yes      |                 | Domain to configure (ex: aleix.cloud)                |
| `prefix`           | String | No       | `email-forward` | All resources will be tagged using this prefix name  |
| `aws_region`       | String | No       | `eu-west-1`     | AWS region where we should configure the integration |
| `dns_provider`     | String | No       | `aws`           | DNS provider where the domain is registered          |

## Attributes

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
|      |      |          |         |             |

## Example 

Let's imagine I want to configure `hello@aleix.cloud` domain to be available to the world, but I don't want to pay for an email service. 

I can use this module to register this email through an existing email, and send all incoming emails to my personal Gmail.

```
module "ses-email-forwarding" {
   source = "git@github.com:superdug/terraform-aws-ses-email-forwarding.git"

    dns_provider     = "aws"
    domain           = "amiblocked.io"
    s3_bucket        = "amiblocked.io.emails"
    s3_bucket_prefix = "emails"
    mail_targets     = ["test@amiblocked.io", "administrator@amiblocked.io", "hostmaster@amiblocked.io", "postmaster@amiblocked.io", "webmaster@amiblocked.io", "admin@amiblocked.io"]
    mail_sender      = "postmaster@amiblocked.io"
    mail_recipient   = "fluentstream@dugnet.com"
}
```
**NOTE**
An email will be sent to the `mail_recepient` address from AWS to you for verifying that you can receive emails at that address before proceeding

## Contributors

All contributors are more than welcome :)