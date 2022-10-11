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
    "istio-tls" = {
      dns_names   = ["istio.local"]
      namespace   = "istio"
      secret_name = "istio-ingressgateway-tls"
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
  istio_chart_name                = var.istio_chart_name
  istio_chart_repository          = var.istio_chart_repository
  istio_chart_version             = var.istio_chart_version
  istio_cluster_name              = var.istio_cluster_name
  istio_mesh_id                   = var.istio_mesh_id
  istio_network                   = var.istio_network
  istio_operator_namespace        = var.istio_operator_namespace
  istio_profile                   = var.istio_profile
  istio_release_name              = var.istio_release_name
  istio_revision_tag              = var.istio_revision_tag
  istio_settings                  = var.istio_settings
  istio_system_namespace          = var.istio_system_namespace
  istio_trust_domain              = var.istio_trust_domain
  istio_gateway_certificate_name  = "istio-ingressgateway-tls"
  istio_gateway_certificate_hosts = ["istio.local"]
  istio_gateway_certificate_issuer = {
    group = "cert-manager.io"
    kind  = "ClusterIssuer"
    name  = "cert-manager"
  }
  istio_values = var.istio_values

  kiali_operator_chart_name       = var.kiali_operator_chart_name
  kiali_operator_chart_repository = var.kiali_operator_chart_repository
  kiali_operator_chart_version    = var.kiali_operator_chart_version
  kiali_operator_release_name     = var.kiali_operator_release_name
  kiali_operator_namespace        = var.kiali_operator_namespace
  kiali_operator_settings         = var.kiali_operator_settings
  kiali_operator_values           = var.kiali_operator_values
  kiali_namespace                 = var.kiali_namespace
  kiali_gateway_hosts             = ["kali-istio.local"]
  kiali_gateway_tls_secret        = "istio-ingressgateway-tls"
  timeout                         = var.timeout
}

locals {
  atomic          = var.atomic != null ? var.atomic : true
  cleanup_on_fail = var.cleanup_on_fail != null ? var.cleanup_on_fail : true
  timeout         = var.timeout != null ? var.timeout : 120

  # Istio Operator Settings
  create_istio_system_namespace             = var.create_istio_system_namespace != null ? var.create_istio_system_namespace : true
  create_istio_operator_namespace           = var.create_istio_operator_namespace != null ? var.create_istio_operator_namespace : true
  istio_chart_name                          = var.istio_chart_name != null ? var.istio_chart_name : "istio-operator"
  istio_chart_repository                    = var.istio_chart_repository != null ? var.istio_chart_repository : "https://stevehipwell.github.io/helm-charts/"
  istio_chart_version                       = var.istio_chart_version != null ? var.istio_chart_version : "2.4.0"
  istio_cluster_name                        = var.istio_cluster_name != null ? var.istio_cluster_name : null
  istio_ingress_gateway_service_annotations = var.istio_ingress_gateway_service_annotations != null ? var.istio_ingress_gateway_service_annotations : {}
  istio_mesh_id                             = var.istio_mesh_id != null ? var.istio_mesh_id : null
  istio_network                             = var.istio_network != null ? var.istio_network : "network1"
  istio_operator_namespace                  = var.istio_operator_namespace != null ? var.istio_operator_namespace : "istio-operator"
  istio_profile                             = var.istio_profile != null ? var.istio_profile : "default"
  istio_release_name                        = var.istio_release_name != null ? var.istio_release_name : "istio-operator"
  istio_revision_tag                        = var.istio_revision_tag != null ? var.istio_revision_tag : "default"
  istio_settings                            = var.istio_settings != null ? var.istio_settings : {}
  istio_system_namespace                    = var.istio_system_namespace != null ? var.istio_system_namespace : "istio-system"
  istio_trust_domain                        = var.istio_trust_domain != null ? var.istio_trust_domain : "cluster.local"
  istio_values                              = var.istio_values != null ? var.istio_values : []
  istio_gateway_certificate_name            = "istio-ingressgateway-tls"
  istio_gateway_certificate_issuer = {
    group = "cert-manager.io"
    kind  = "ClusterIssuer"
    name  = "cert-manager"
  }
  # Kiali Operator Settings
  create_kiali_cr                 = var.create_kiali_cr != null ? var.create_kiali_cr : true
  create_kiali_operator_namespace = var.create_kiali_operator_namespace != null ? var.create_kiali_operator_namespace : true
  kiali_operator_chart_name       = var.kiali_operator_chart_name != null ? var.kiali_operator_chart_name : "kiali-operator"
  kiali_operator_chart_repository = var.kiali_operator_chart_repository != null ? var.kiali_operator_chart_repository : "https://kiali.org/helm-charts"
  kiali_operator_chart_version    = var.kiali_operator_chart_version != null ? var.kiali_operator_chart_version : "1.45.0"
  kiali_operator_release_name     = var.kiali_operator_release_name != null ? var.kiali_operator_release_name : "kiali-operator"
  kiali_operator_settings         = var.kiali_operator_settings != null ? var.kiali_operator_settings : {}
  kiali_operator_namespace        = var.kiali_operator_namespace != null ? var.kiali_operator_namespace : "kiali-operator"
  kiali_namespace                 = var.kiali_namespace != null ? var.kiali_namespace : local.istio_system_namespace
  kiali_release_name              = var.kiali_release_name != null ? var.kiali_release_name : "kiali"
  kiali_gateway_hosts             = var.kiali_gateway_hosts != null ? var.kiali_gateway_hosts : []
  kiali_gateway_tls_secret        = var.kiali_gateway_tls_secret != null ? var.kiali_gateway_tls_secret : "kiali"
}

resource "kubernetes_namespace" "istio_system" {
  count = local.create_istio_system_namespace ? 1 : 0
  metadata {
    name = var.istio_system_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels
    ]
  }
}

resource "helm_release" "istio_operator" {
  count            = var.enable_istio_operator ? 1 : 0
  atomic           = var.atomic
  chart            = var.istio_chart_name
  cleanup_on_fail  = var.cleanup_on_fail
  create_namespace = var.create_istio_operator_namespace
  name             = var.istio_release_name
  namespace        = var.istio_operator_namespace
  timeout          = var.timeout
  repository       = var.istio_chart_repository
  version          = var.istio_chart_version

  values = coalescelist(local.istio_values, [templatefile("${path.module}/values.yaml.tpl", {
    cluster_name                        = local.istio_cluster_name
    mesh_id                             = local.istio_mesh_id
    network                             = local.istio_network
    revision_tag                        = local.istio_revision_tag
    istio_system_namespace              = local.create_istio_system_namespace ? kubernetes_namespace.istio_system[0].metadata[0].name : var.istio_system_namespace
    profile                             = local.istio_profile
    trust_domain                        = local.istio_trust_domain
    ingress_gateway_service_annotations = local.istio_ingress_gateway_service_annotations
    })]
  )

  dynamic "set" {
    for_each = local.istio_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  mesh_values = yamlencode({
    ingressGateway = {
      tlsCertificate = {
        name       = local.istio_gateway_certificate_name
        secretName = local.istio_gateway_certificate_name
        dnsNames   = var.istio_gateway_certificate_hosts
        issuerRef  = local.istio_gateway_certificate_issuer
      }
    }
  })
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [resource.helm_release.istio_operator]

  create_duration = "30s"
}

resource "helm_release" "mesh" {
  count           = var.enable_istio_operator ? 1 : 0
  atomic          = local.atomic
  name            = "mesh"
  namespace       = local.create_istio_system_namespace ? kubernetes_namespace.istio_system[0].metadata[0].name : local.istio_system_namespace
  chart           = "./modules/istio-operator/charts/mesh"
  cleanup_on_fail = local.cleanup_on_fail
  timeout         = local.timeout
  values          = [local.mesh_values]

  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

locals {
  kiali_operator_values = var.kiali_operator_values != null ? var.kiali_operator_values : yamlencode({
    cr = {
      create    = local.create_kiali_cr
      namespace = local.kiali_namespace
      spec = {
        deployment = {
          accessible_namespaces = ["**"]
          ingress = {
            enabled = false
          }
          pod_labels = {
            "service.istio.io/canonical-name" : "kiali"
            "service.istio.io/canonical-revision" : local.kiali_operator_chart_version
          }
        }
        istio_labels = {
          app_label_name     = "service.istio.io/canonical-name"
          version_label_name = "service.istio.io/canonical-revision"
        }
        kiali_feature_flags = {
          istio_injection_action = false
          istio_upgrade_action   = false
          ui_defaults = {
            metrics_per_refresh = "10m"
          }
        }
        external_services = {
          istio = {
            config_map_name        = "istio-${local.istio_revision_tag}"
            istiod_deployment_name = "istiod-${local.istio_revision_tag}"
            root_namespace         = local.create_istio_system_namespace ? kubernetes_namespace.istio_system[0].metadata[0].name : local.istio_system_namespace
          }
          prometheus = {
            url = "http://prometheus-server.${local.istio_system_namespace}.svc.cluster.local"
          }
          tracing = {
            enabled = false
          }
        }
      }
    }
  })
}

resource "helm_release" "kiali_operator" {
  count            = var.enable_kiali_operator ? 1 : 0
  atomic           = local.atomic
  chart            = local.kiali_operator_chart_name
  cleanup_on_fail  = local.cleanup_on_fail
  create_namespace = local.create_kiali_operator_namespace
  name             = local.kiali_operator_release_name
  namespace        = local.kiali_operator_namespace
  repository       = local.kiali_operator_chart_repository
  timeout          = local.timeout
  version          = local.kiali_operator_chart_version
  values           = [local.kiali_operator_values]

  dynamic "set" {
    for_each = local.kiali_operator_settings
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    resource.helm_release.mesh
  ]
}

locals {
  kiali_values = var.kiali_values != null ? var.kiali_values : yamlencode({
    gatewaySelector = {
      "cloud.streamnative.io/role" = "istio-ingressgateway"
    }
    gatewayTls = {
      mode           = "SIMPLE"
      credentialName = local.kiali_gateway_tls_secret
    }
    gatewayHosts = local.kiali_gateway_hosts
    kialiSelector = {
      "app.kubernetes.io/name"     = "kiali" # A constant
      "app.kubernetes.io/instance" = "kiali" # Kiali CR name
    }
    kialiHost = "kiali.${local.kiali_namespace}.svc.cluster.local"
  })
}

resource "helm_release" "kiali" {
  count           = var.enable_kiali_operator ? 1 : 0
  name            = local.kiali_release_name
  namespace       = local.kiali_namespace
  chart           = "./modules/istio-operator/charts/kiali"
  atomic          = local.atomic
  cleanup_on_fail = local.cleanup_on_fail
  timeout         = local.timeout
  values          = [local.kiali_values]

  depends_on = [
    resource.helm_release.kiali_operator
  ]
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

