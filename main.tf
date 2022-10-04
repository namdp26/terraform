provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "my-context"
  }
}

module "cert_manager" {
  source                                 = "./modules/cert-manager-k8s"
  cluster_issuer_email                   = var.cluster_issuer_email
  cluster_issuer_name                    = var.cluster_issuer_name
  cluster_issuer_private_key_secret_name = var.cluster_issuer_private_key_secret_name
}

module "certificate" {
  source            = "./modules/cert-manager-k8s/modules/_certificate"
  name              = "gitlab-zinza"
  dns_names         = var.dns_names
  namespace         = var.namespace_name
  issuer_name       = var.cluster_issuer_name
  issuer_kind       = "ClusterIssuer"
  secret_name       = "gitlab-zinza"
  issuer_group      = var.issuer_group
}

module "istio_operator" {
  source = "./modules/istio-operator"

  create_istio_system_namespace   = var.create_istio_system_namespace
  create_istio_operator_namespace = var.create_istio_operator_namespace
  create_kiali_cr                 = var.create_kiali_cr
  create_kiali_operator_namespace = var.create_kiali_operator_namespace
  enable_istio_operator           = var.enable_istio_operator
  enable_kiali_operator           = var.enable_kiali_operator
  istio_chart_name                = var.istio_operator_chart_name
  istio_chart_repository          = var.istio_operator_chart_repository
  istio_chart_version             = var.istio_operator_chart_version
  istio_cluster_name              = var.istio_cluster_name
  istio_mesh_id                   = var.istio_mesh_id
  istio_network                   = var.istio_network
  istio_operator_namespace        = var.istio_operator_namespace
  istio_profile                   = var.istio_profile
  istio_release_name              = var.istio_operator_release_name
  istio_revision_tag              = var.istio_revision_tag
  istio_settings                  = var.istio_operator_settings
  istio_system_namespace          = var.istio_system_namespace
  istio_trust_domain              = var.istio_trust_domain
  istio_gateway_certificate_name  = "istio-ingressgateway-tls"
  # istio_gateway_certificate_hosts = ["*.${var.service_domain}"]
  istio_gateway_certificate_issuer = {
    group = var.issuer_group
    kind  = "ClusterIssuer"
    name  = "external"
  }
  istio_values = var.istio_operator_values

  kiali_operator_chart_name       = var.kiali_operator_chart_name
  kiali_operator_chart_repository = var.kiali_operator_chart_repository
  kiali_operator_chart_version    = var.kiali_operator_chart_version
  kiali_operator_release_name     = var.kiali_operator_release_name
  kiali_operator_namespace        = var.kiali_operator_namespace
  kiali_operator_settings         = var.kiali_operator_settings
  kiali_operator_values           = var.kiali_operator_values
  kiali_namespace                 = var.kiali_namespace
  # kiali_gateway_hosts             = ["kiali.${var.service_domain}"]
  kiali_gateway_tls_secret        = "istio-ingressgateway-tls"
  timeout                         = var.istio_operator_timeout
}

