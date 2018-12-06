variable "cloudflare_email" {
  description = "Cloudflare email to access api"
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key to access api"
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
