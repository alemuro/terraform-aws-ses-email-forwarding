resource "cloudflare_record" "dkim" {
  domain = var.domain
  name   = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  value  = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.${var.domain}"
  type   = "CNAME"
  ttl    = 600

  count = local.use_cloudflare ? 3 : 0
}

resource "cloudflare_record" "verification" {
  domain = var.domain
  name   = "_amazonses.${var.domain}"
  value  = aws_ses_domain_identity.domain.verification_token
  type   = "TXT"
  ttl    = 600

  count = local.use_cloudflare ? 1 : 0
}

resource "cloudflare_record" "mx" {
  domain   = var.domain
  name     = var.domain
  value    = "inbound-smtp.${var.aws_region}.amazonaws.com"
  type     = "MX"
  priority = 10

  count = local.use_cloudflare ? 1 : 0
}
