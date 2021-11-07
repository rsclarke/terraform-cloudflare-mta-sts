# terraform-cloudflare-mta-sts

This module creates the necessary DNS records to support MTA-STS and SMTP TLS reporting.  In addition, a Cloudflare Worker serves the MTA-STS policy, note that this worker does not accept the reports and you must specify a location which does through the `rua` variable.

## Usage

```terraform

resource "cloudflare_zone" "example_com" {
  zone = "example.com"
}

module {
  source = "rsclarke/mta-sts/cloudflare"

  zone_id   = cloudflare_zone.example_com.id
  zone_name = cloudflare_zone.example_com.name

  mode    = "enforce"
  mx      = ["mx1.example.com", "mx2.example.net"]
  max_age = 604800 # 1 week in seconds
  rua     = ["mailto:tls_report@example.org", "https://example.org/mta-sts/report"]
}
```

## Providers

| Name | Version |
|------|---------|
| cloudflare | `>= 2.0` |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| zone_id | Cloudflare Zone ID | `string` | yes |
| zone_name | Cloudflare Zone Name | `string` | yes |
| mode | Sending MTA policy application, [rfc8461#section-5](https://tools.ietf.org/html/rfc8461#section-5).  Default `testing` | `string` | no |
| mx | List of permitted MX hosts, at least one | `list(string)` | yes |
| max_age | Maximum lifetime of the policy in seconds, up to 31557600, defaults to 604800 (1 week) | `number` | no |
| rua | Locations to which aggregate reports about policy violations should be sent, either `mailto:` or `https:` schema. | `list(string)` | yes |

## Outputs

This module does not expose any outputs.
