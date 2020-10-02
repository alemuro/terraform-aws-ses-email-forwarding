data "cloudflare_zones" "selected" {
  filter {
    name        = var.domain
    lookup_type = "exact"
    status      = "active"
  }
}

resource "cloudflare_record" "dkim" {
  zone_id = lookup(data.cloudflare_zones.selected.zones[0], "id")
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  value   = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"
  type    = "CNAME"
  ttl     = 600

  count = local.use_cloudflare ? 3 : 0
}

resource "cloudflare_record" "verification" {
  zone_id = lookup(data.cloudflare_zones.selected.zones[0], "id")
  name    = "_amazonses.${var.domain}"
  value   = aws_ses_domain_identity.domain.verification_token
  type    = "TXT"
  ttl     = 600

  count = local.use_cloudflare ? 1 : 0
}

resource "cloudflare_record" "mx" {
  zone_id  = lookup(data.cloudflare_zones.selected.zones[0], "id")
  name     = var.domain
  value    = "inbound-smtp.${var.aws_region}.amazonaws.com"
  type     = "MX"
  priority = 10

  count = local.use_cloudflare ? 1 : 0
}
