variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "zone_name" {
  type        = string
  description = "Cloudflare Zone Name"
}

variable "mode" {
  type        = string
  default     = "testing"
  description = "Sending MTA policy application, https://tools.ietf.org/html/rfc8461#section-5"

  validation {
    condition     = contains(["enforce", "testing", "none"], var.mode)
    error_message = "Only `enforce` `testing` or `none` is valid."
  }
}

variable "mx" {
  type        = list(string)
  description = "List of permitted MX hosts"

  validation {
    condition     = length(var.mx) != 0
    error_message = "At least 1 MX host specified."
  }
}

variable "max_age" {
  type        = number
  default     = 604800 # 1 week
  description = "Maximum lifetime of the policy in seconds, up to 31557600, defaults to 604800 (1 week)"

  validation {
    condition     = var.max_age >= 0
    error_message = "Policy validity time must be positive."
  }

  validation {
    condition     = var.max_age <= 31557600
    error_message = "Policy validity time must be less than 1 year (31557600 seconds)."
  }
}

variable "rua" {
  type        = list(string)
  description = "Locations to which aggregate reports about policy violations should be sent, either `mailto:` or `https:` schema."

  validation {
    condition     = length(var.rua) != 0
    error_message = "At least one `mailto:` or `https:` endpoint provided."
  }

  validation {
    condition     = can([for loc in var.rua : regex("^(mailto|https):", loc)])
    error_message = "Locations must start with either the `mailto: or `https` schema."
  }
}
