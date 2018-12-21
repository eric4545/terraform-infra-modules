resource "tls_private_key" "debugger" {
  algorithm   = "RSA"
  ecdsa_curve = "4096"
}

resource "aws_key_pair" "debugger" {
  key_name   = "debugger-key"
  public_key = "${tls_private_key.debugger.public_key_openssh }"
}
