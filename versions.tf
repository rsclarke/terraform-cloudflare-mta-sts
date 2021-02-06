terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 2.0"
    }
  }

  required_version = "~> 0.14.0"
}
