## K8s config
variable "kube_config" {
  type = string
  default = "/home/namdp/.config/Lens/kubeconfigs/7c9058cc-dffa-4801-8d24-91d88360f661"
}

variable "k8s_context" {
  type = string
  default = "kubernetes-admin@k8s.local"
}

## Cert-manager

variable "namespace_name" {
  default = "cert-manager"
}

variable "cluster_issuer_email" {
  description = "Email address used for ACME registration"
  type        = string
  default     = "hunglq@zinza.com.vn"
}

variable "cluster_issuer_name" {
  description = "Cluster Issuer Name, used for annotations"
  type        = string
  default     = "cert-manager"
}

variable "cluster_issuer_private_key_secret_name" {
  description = "Name of a secret used to store the ACME account private key"
  type        = string
  default     = "cert-manager-private-key"
}

variable "dns_names" {
  type        = list(string)
  default     = [
    "gitlab.example.com",
    "regitry.example.com",
  ]
}

variable "issuer_group" {
  type        = string
  description = "issuer group"
  default     = "cert-manager.io"
}

variable "chart_version" {
  type        = string
  description = "HELM Chart Version for cert-manager"
  default     = "1.7.1"
}

variable "cluster_issuer_server" {
  description = "The ACME server URL"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "solvers" {
  description = "List of Cert manager solvers. For a complex example please look at the Readme"
  type        = any
  default = [{
    http01 = {
      ingress = {
        class = "nginx"
      }
    }
  }]
}

### Istio
variable "create_istio_operator_namespace" {
  default     = true
  description = "Create a namespace for the deployment. Defaults to \"true\"."
  type        = bool
}

variable "create_istio_system_namespace" {
  default     = false
  description = "Create a namespace where istio components will be installed."
  type        = bool
}

variable "istio_operator_namespace" {
  default     = "istio-operator"
  description = "The namespace used for the Istio operator deployment"
  type        = string
}

variable "istio_system_namespace" {
  default     = "sn-system"
  description = "The namespace used for the Istio components."
  type        = string
}

### Kiali
variable "create_kiali_operator_namespace" {
  default     = true
  description = "Create a namespace for the deployment."
  type        = bool
}

variable "kiali_namespace" {
  default     = "sn-system"
  description = "The namespace used for the Kiali operator."
  type        = string
}

variable "kiali_operator_namespace" {
  default     = "kiali-operator"
  description = "The namespace used for the Kiali operator deployment"
  type        = string
}
### Istio Settings
#######


variable "istio_operator_chart_name" {
  default     = null
  description = "The name of the Helm chart to install"
  type        = string
}

variable "istio_operator_chart_repository" {
  default     = null
  description = "The repository containing the Helm chart to install"
  type        = string
}

variable "istio_operator_chart_version" {
  default     = null
  description = "The version of the Helm chart to install. Set to the submodule default."
  type        = string
}

variable "istio_mesh_id" {
  default     = null
  description = "The ID used by the Istio mesh. This is also the ID of the StreamNative Cloud Pool used for the workload environments. This is required when \"enable_istio_operator\" is set to \"true\"."
  type        = string
}

variable "istio_cluster_name" {
  default     = null
  description = "The name of the kubernetes cluster where Istio is being configured. This is required when \"enable_istio_operator\" is set to \"true\"."
  type        = string
}

variable "istio_network" {
  default     = null
  description = "The name of network used for the Istio deployment."
  type        = string
}

variable "istio_profile" {
  default     = null
  description = "The path or name for an Istio profile to load. Set to the profile \"default\" if not specified."
  type        = string
}

variable "istio_operator_release_name" {
  default     = null
  description = "The name of the helm release"
  type        = string
}

variable "istio_revision_tag" {
  default     = null
  description = "The revision tag value use for the Istio label \"istio.io/rev\". Defaults to \"sn-stable\"."
  type        = string
}

variable "istio_operator_settings" {
  default     = null
  description = "Additional key value settings which will be passed to the Helm chart values, e.g. { \"namespace\" = \"kube-system\" }."
  type        = map(any)
}

variable "istio_operator_timeout" {
  default     = null
  description = "Time in seconds to wait for any individual kubernetes operation"
  type        = number
}

variable "istio_trust_domain" {
  default     = null
  description = "The trust domain used for the Istio operator, which corresponds to the root of a system. This is required when \"enable_istio_operator\" is set to \"true\"."
  type        = string
}

variable "istio_operator_values" {
  default     = null
  description = "Additional key value settings which will be passed to the Helm chart values, e.g. { \"namespace\" = \"kube-system\" }."
}

#######
### Kiali Settings
#######
variable "create_kiali_cr" {
  default     = null
  description = "Create a Kiali CR for the Kiali deployment."
  type        = bool
}

variable "kiali_operator_chart_name" {
  default     = null
  description = "The name of the Helm chart to install"
  type        = string
}

variable "kiali_operator_chart_repository" {
  default     = null
  description = "The repository containing the Helm chart to install"
  type        = string
}

variable "kiali_operator_chart_version" {
  default     = null
  description = "The version of the Helm chart to install. Set to the submodule default."
  type        = string
}

variable "kiali_operator_release_name" {
  default     = null
  description = "The name of the Kiali release"
  type        = string
}

variable "kiali_operator_settings" {
  default     = null
  description = "Additional key value settings which will be passed to the Helm chart values, e.g. { \"namespace\" = \"kube-system\" }."
  type        = map(any)
}

variable "kiali_operator_values" {
  default     = null
  description = "A list of values in raw YAML to be applied to the helm release. Merges with the settings input, can also be used with the `file()` function, i.e. `file(\"my/values.yaml\")`."
}

### Enable/Disable sub-modules
variable "enable_olm" {
  default     = false
  description = "Enables Operator Lifecycle Manager (OLM), and disables installing operators via Helm. OLM is disabled by default. Set to \"true\" to have OLM manage the operators."
  type        = bool
}

variable "enable_function_mesh_operator" {
  default     = true
  description = "Enables the StreamNative Function Mesh Operator. Set to \"true\" by default, but disabled if OLM is enabled."
  type        = bool
}

variable "enable_istio_operator" {
  default     = false
  description = "Enables the Istio Operator. Set to \"false\" by default."
  type        = bool
}

variable "enable_kiali_operator" {
  default     = false
  description = "Enables the Kiali Operator. Set to \"false\" by default."
  type        = bool
}

variable "enable_otel_collector" {
  default     = false
  description = "Enables Open Telemetry. Set to \"false\" by default."
  type        = bool
}

variable "enable_prometheus_operator" {
  default     = true
  description = "Enables the Prometheus Operator and other components via kube-stack-prometheus. Set to \"true\" by default."
  type        = bool
}

variable "enable_pulsar_operator" {
  default     = true
  description = "Enables the Pulsar Operator on the EKS cluster. Enabled by default, but disabled if var.disable_olm is set to `true`"
  type        = bool
}

variable "enable_vault_operator" {
  default     = true
  description = "Enables Hashicorp Vault on the EKS cluster."
  type        = bool
}

variable "enable_vector_agent" {
  default     = false
  description = "Enables the Vector Agent on the EKS cluster. Enabled by default, but must be passed a configuration in order to function"
  type        = bool
}

variable "enable_vmagent" {
  default     = false
  description = "Enables the Victoria Metrics stack on the EKS cluster. Disabled by default"
  type        = bool
}

variable "enable_cma" {
  default     = false
  description = "Enables Cloud Manager Agent. Disabled by default."
  type        = bool
}

### Top-level Variables

### Networking
#######

variable "service_domain" {
  default     = null
  description = "The DNS domain for external service endpoints. This must be set when enabling Istio or else the deployment will fail."
  type        = string
}
