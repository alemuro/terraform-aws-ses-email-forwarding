data "aws_route53_zone" "selected" {
  name  = "${var.domain}."
  count = local.use_aws ? 1 : 0
}

resource "aws_route53_record" "dkim" {
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.${var.domain}"]

  count = local.use_aws ? 3 : 0
}

resource "aws_route53_record" "verification" {
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain.verification_token]

  count = local.use_aws ? 1 : 0
}

resource "aws_route53_record" "mx" {
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com"]

  count = local.use_aws ? 1 : 0
}
