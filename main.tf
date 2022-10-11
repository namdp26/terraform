provider "kubernetes" {
  config_context         = var.k8s_context
  config_path            = var.kube_config
  host                   = var.host
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    config_context         = var.k8s_context
    config_path            = var.kube_config
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
  }
}

module "cert_manager" {
  source                                 = "./modules/cert-manager-k8s"
  cluster_issuer_email                   = "hunglq@zinza.com.vn"
  cluster_issuer_name                    = var.cluster_issuer_name
  cluster_issuer_private_key_secret_name = var.cluster_issuer_private_key_secret_name
  solvers                                = var.solvers
  certificates = {
    "gitlab-tls" = {
      dns_names   = ["gitlab.example.com"]
      namespace   = "gitlab"
      secret_name = "gitlab-tls"
    }
  }
}

module "certificate" {
  for_each = { for k, v in var.certificates : k => v }
  source   = "./modules/cert-manager-k8s/modules/_certificate"

  name                  = each.key
  namespace             = try(each.value.namespace, var.namespace_name)
  secret_name           = try(each.value.secret_name, "${each.key}-tls")
  secret_annotations    = try(each.value.secret_annotations, {})
  secret_labels         = try(each.value.secret_labels, {})
  duration              = try(each.value.duration, "2160h")
  renew_before          = try(each.value.renew_before, "360h")
  organizations         = try(each.value.organizations, [])
  is_ca                 = try(each.value.is_ca, false)
  private_key_algorithm = try(each.value.private_key_algorithm, "RSA")
  private_key_encoding  = try(each.value.private_key_encoding, "PKCS1")
  private_key_size      = try(each.value.private_key_size, 2048)
  usages                = try(each.value.usages, ["server auth", "client auth", ])
  dns_names             = each.value.dns_names
  uris                  = try(each.value.uris, [])
  ip_addresses          = try(each.value.ip_addresses, [])
  issuer_name           = try(each.value.issuer_name, var.cluster_issuer_name)
  issuer_kind           = try(each.value.issuer_kind, "ClusterIssuer")
  issuer_group          = try(each.value.issuer_group, "")
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
  kiali_gateway_tls_secret = "istio-ingressgateway-tls"
  timeout                  = var.istio_operator_timeout
}

