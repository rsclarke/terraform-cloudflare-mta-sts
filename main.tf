locals {
  policy    = templatefile("${path.module}/policy.tpl", { mode = var.mode, mx = var.mx, max_age = floor(var.max_age) })
  policy_id = md5(local.policy)
}

resource "cloudflare_dns_record" "smtp_tls" {
  zone_id = var.zone_id
  name    = "_smtp._tls"
  type    = "TXT"
  content = "v=TLSRPTv1; rua=${join(",", var.rua)}"
  ttl     = 1
}

resource "cloudflare_dns_record" "mta_sts" {
  zone_id = var.zone_id
  name    = "_mta-sts"
  type    = "TXT"
  content = "v=STSv1; id=${local.policy_id}"
  ttl     = 1
}

resource "cloudflare_dns_record" "a" {
  zone_id = var.zone_id
  name    = "mta-sts"
  type    = "A"
  content = "192.0.2.1"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "aaaa" {
  zone_id = var.zone_id
  name    = "mta-sts"
  type    = "AAAA"
  content = "100::"
  proxied = true
  ttl     = 1
}

resource "cloudflare_workers_kv_namespace" "mta_sts" {
  account_id = var.account_id
  title      = "mta-sts.${var.zone_name}"
}

resource "cloudflare_workers_kv" "mta_sts" {
  account_id   = var.account_id
  namespace_id = cloudflare_workers_kv_namespace.mta_sts.id
  key_name     = "policy"
  value        = local.policy
}

resource "cloudflare_workers_script" "mta_sts_policy" {
  account_id  = var.account_id
  script_name = "mta-sts-${replace(var.zone_name, ".", "-")}"
  content     = file("${path.module}/mta_sts.js")

  bindings = [{
    name         = "POLICY_NAMESPACE"
    type         = "kv_namespace"
    namespace_id = cloudflare_workers_kv_namespace.mta_sts.id
  }]
}

resource "cloudflare_workers_route" "mta_sts" {
  zone_id = var.zone_id
  pattern = "mta-sts.${var.zone_name}/*"
  script  = cloudflare_workers_script.mta_sts_policy.script_name
}
