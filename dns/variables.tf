variable "cloudflare_email" {
  description = "Cloudflare email to access api"
}

variable "cloudflare_token" {
  description = "Cloudflare token to access api"
}

variable "lb_address" {
  description = "Loadbalancer IP address"
}

variable "domain" {
  description = "domain"
}

variable "domain_records" {
  description = "List of domain record"
  type        = "list"
}
