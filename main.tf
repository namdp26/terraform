module "cert_manager" {
  source                                 = "./terraform-kubernetes-cert-manager"
  cluster_issuer_email                   = "hunglq@zinza.com.vn"
  cluster_issuer_name                    = "staging-letsencrypt"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  dns_names                              = "gitlab.zinza.com"
}