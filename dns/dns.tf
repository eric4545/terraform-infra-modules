provider "cloudflare" {
  version = "~> 1.2"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}

resource "cloudflare_record" "record" {
  count   = "${length(var.domain_records)}"
  domain  = "${var.domain}"
  name    = "${element(var.domain_records, count.index)}"
  value   = "${var.lb_address}"
  type    = "A"
  ttl     = 1
  proxied = true
}
