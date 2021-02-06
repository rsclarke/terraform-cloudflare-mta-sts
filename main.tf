locals {
  policy    = templatefile("${path.module}/policy.tpl", { mode = var.mode, mx = var.mx, max_age = floor(var.max_age) })
  policy_id = md5(local.policy)
}

resource "cloudflare_record" "smtp_tls" {
  zone_id = var.zone_id
  name    = "_smtp._tls"
  type    = "TXT"
  value   = "v=TLSRPTv1; rua=${join(",", var.rua)}"
}

resource "cloudflare_record" "mta_sts" {
  zone_id = var.zone_id
  name    = "_mta-sts"
  type    = "TXT"
  value   = "v=STSv1; id=${local.policy_id}"
}

resource "cloudflare_record" "a" {
  zone_id = var.zone_id
  name    = "mta-sts"
  type    = "A"
  value   = "192.0.2.1"
}

resource "cloudflare_record" "aaaa" {
  zone_id = var.zone_id
  name    = "mta-sts"
  type    = "AAAA"
  value   = "100::"
}

resource "cloudflare_workers_kv_namespace" "mta_sts" {
  title = "mta-sts.${var.zone_name}"
}

resource "cloudflare_workers_kv" "mta_sts" {
  namespace_id = cloudflare_workers_kv_namespace.mta_sts.id
  key          = "policy"
  value        = local.policy
}

resource "cloudflare_worker_script" "mta_sts_policy" {
  name    = "mta-sts-${replace(var.zone_name, ".", "-")}"
  content = file("${path.module}/mta_sts.js")

  kv_namespace_binding {
    name         = "POLICY_NAMESPACE"
    namespace_id = cloudflare_workers_kv_namespace.mta_sts.id
  }
}

resource "cloudflare_worker_route" "mta_sts" {
  zone_id     = var.zone_id
  pattern     = "mta-sts.${var.zone_name}/*"
  script_name = cloudflare_worker_script.mta_sts_policy.name
}
