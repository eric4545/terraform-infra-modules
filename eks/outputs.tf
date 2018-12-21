output "kubeconfig" {
  value     = "${local.kubeconfig}"
  sensitive = true
}

output "debugger_private_key" {
  value     = "${tls_private_key.debugger.private_key_pem }"
  sensitive = true
}
