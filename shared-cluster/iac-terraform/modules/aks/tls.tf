# We manage cert stuff differently, but this can be useful if you want to do it all through terraform

# resource "tls_private_key" "root" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_self_signed_cert" "root" {
#   private_key_pem = tls_private_key.root.private_key_pem

#   subject {
#     common_name = "My Root CA"
#   }

#   is_ca_certificate     = true
#   validity_period_hours = 87600 # Approximately 10 years

#   allowed_uses = [
#     "cert_signing",
#     "crl_signing"
#   ]
# }


# resource "tls_private_key" "ingress" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_cert_request" "ingress" {
#   private_key_pem = tls_private_key.ingress.private_key_pem

#   subject {
#     common_name  = "Cluster Ingress To-Be-Trusted-By-Gateway"
#     organization = "My Org"
#   }

#   dns_names = [
#     "*.dev.cloud.org.canada.ca",
#     "*.dev.cloud.org.gc.ca"
#   ]
# }

# resource "tls_locally_signed_cert" "ingress" {
#   cert_request_pem = tls_cert_request.ingress.cert_request_pem

#   ca_private_key_pem = tls_private_key.root.private_key_pem
#   ca_cert_pem        = tls_self_signed_cert.root.cert_pem

#   validity_period_hours = 8760 # 1 year

#   allowed_uses = [
#     "server_auth",
#   ]
# }
