## K8s connection
variable "kube_config" {
  type    = string
  default = "/home/namdp/.config/Lens/kubeconfigs/720fb5c6-0a32-4f5f-b726-2092be7ab64e"
}

variable "k8s_context" {
  type    = string
  default = "minikube"
}

variable "host" {
  type    = string
  default = "https://192.168.59.101:8443"
}

variable "client_certificate" {
  type    = string
  default = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRJeU1UQXdOVEE1TVRjeE4xb1hEVE15TVRBd016QTVNVGN4TjFvd0ZURVRNQkVHQTFVRQpBeE1LYldsdWFXdDFZbVZEUVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTFhYCmlqUXA5MDh2Y1JwWlk1USs3dm1JR0FuL25wbng5bnFGcktvdWMvL2oyVHoweUVEVUtmV1hsd2VEUVlRbUR2UkEKbnRLd2V5S3p2a3FnV3MvNDZxRVZuN09sQmF4UDExM29UbWhBWHhKMGxPV1hoMW5hTW9FQlhkSERnZWNFVDlTYwpTcVBEY3g0MUlQQTc1TmlFUjNrWVNtOUNmMDM1eGxtV3BNN080M20xRnJxdXZNYVRyc0tJbE9LZmlqV2dkbjM4CkUvYUk4cEV4VEZvSXlxQ2VzRi8yTld4UE11ZVN4aitRdG92ZUZnS2dCdldqSGNiWFNHS1BCT2RTcys5bzRYKzQKUTFyNDc1OFdIdVFGM3ZBL3l1NFpXV3p3Y24vcmFuald0T25HZmZYUjAvMWtWNjA3dU1GbmpUM3ZtL3F0UXNNUApnSVZ2aXFlLzRQK00wWlZ0MDBrQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJRdUFwQ3oxdTh5M0w4QlYzdjNwQkg5Mjg4ZmNqQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFxRjlsSTFtbQp6aFlIZDQ1UTZTd3YzeFA5dDBSSGVlQWhkTEpOTnF5ZzdSdThlSjEwRWVjMXlCd1NYU3czVVh2YTE4YWtQYy9yClFPSkNHY21KT0ExNEo1NEczM2pGMWpZeUlUa092a3lwdWlxTUFRU2taQ0ozQU1iT1BEaSszNHhTcnBvUm9sbUMKVXlxYU0vdzdZOHN1b0dLdjY2TFpkSG1GYktoeXdOWXBJbzNPcDlMd00wa21oM3kzQmNyOTdkb0VRYno5SzZaVQpqeDY4L3g4ejNyTXNsVFk0cStOWkFLa29qNG95RkVva1lURGNWQUx4Ui9ZK0UvVUNGMGVnRzk2NEtVYWJ3cXRTCno4REZFRG5ZTEVseTY2WnRqRW1wSUt4Tzh0NWRDUTZUOXkrWnY0bmg3UzlSdTY2WURwdjdDNG9FNnVSUWN5dFQKdkt2Yko2d3JUKytPNGc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg"
}

variable "client_key" {
  type    = string
  default = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lCQWpBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRJeU1UQXdOVEV3TWpReU5sb1hEVEkxTVRBd05URXdNalF5Tmxvd01URVhNQlVHQTFVRQpDaE1PYzNsemRHVnRPbTFoYzNSbGNuTXhGakFVQmdOVkJBTVREVzFwYm1scmRXSmxMWFZ6WlhJd2dnRWlNQTBHCkNTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDNGNBVCtrYXc1cThFaHR5aTBNQ25Rbk9VOFViRUIKV0ZMT0Z1Q2VBUkpWd0JxQ3NSVU0wU3cwVm9yQTN2TEZDS0g2NTdvLzBMYWcvL29xNG93bnJsUi9ac1pnL0ZnZAo5ZTVWMGJmM1RGOFdKa3Z0REpUTzlVK0Zwdm1sVWIzdUhDVUdlUXhpMnNmSVY4WnRvR0NzQXFFU253T28wNjVLCnZyeHJ1ZGRxN2dNa2ZnVjhsL0U5eTZQYlNtRkc3MUk4OEt3VGx5SUhEMGlWVytGRlVYQzhzdlRTN3RQWWRPc1AKRUtsaHlkYk9EQ3RRU1d6YjkwK0piMUlpbTNCdXJkdVpBaDIwdnFyVFU2Nnp6RndZSytEczZ1aGRnVW8yTG9qLwpQaUJ1TUxTVmEwM3BWZEgvYVN6ZXI3TGV5eVdrNmFTVGMwNTNNbXFlYWFyanBaTUlpUFpOMmI3TEFnTUJBQUdqCllEQmVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQWRCZ05WSFNVRUZqQVVCZ2dyQmdFRkJRY0RBUVlJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JRdUFwQ3oxdTh5M0w4QlYzdjNwQkg5Mjg4ZgpjakFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBUVFNNVBYNnpuK3JDNEY2S0M2NlBqWGhXRG5oSnJ3OXZPQkxOCkZ2UEoyN3RLd2RYN1NETk5hbGp4eDlGZnh0dFNDZjdMVHNYRGdMdlpCVXNDbXhKNXQxQnp0RmkybjVmM3U3Y24Kd2NjVk51K1YrenU0MU9ROXhzRUhmR3JNb2ptbHl1UHdRUTBac3dKc2JEWXRVSlRvVlExNUg1RlFCak9lOTN6VgpXNitjWWtrLzY2UEVQeklaMUhuWDNydU80bkE2NUk0WC9uR0FkdUx5YVAxZ3VlTkY0UzJhdUtTeUNHOEtnSVdwCkZQUzlEL1VLdHFNMHFmRnZ0K1pNL3BVTU01SGtTL2o0T3FQSVZaN1NhTWRUYWdndVNqYkNITEkrRXl2VEZSNG0KNG5SaDgvbFJHbE1NUTQrZTZEK2NadHN6QWtWSW10Q1c5bncxL2tIdm5HRU9XN015R1E9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg"
}

variable "cluster_ca_certificate" {
  type    = string
  default = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lCQWpBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRJeU1UQXdOVEV3TWpReU5sb1hEVEkxTVRBd05URXdNalF5Tmxvd01URVhNQlVHQTFVRQpDaE1PYzNsemRHVnRPbTFoYzNSbGNuTXhGakFVQmdOVkJBTVREVzFwYm1scmRXSmxMWFZ6WlhJd2dnRWlNQTBHCkNTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDNGNBVCtrYXc1cThFaHR5aTBNQ25Rbk9VOFViRUIKV0ZMT0Z1Q2VBUkpWd0JxQ3NSVU0wU3cwVm9yQTN2TEZDS0g2NTdvLzBMYWcvL29xNG93bnJsUi9ac1pnL0ZnZAo5ZTVWMGJmM1RGOFdKa3Z0REpUTzlVK0Zwdm1sVWIzdUhDVUdlUXhpMnNmSVY4WnRvR0NzQXFFU253T28wNjVLCnZyeHJ1ZGRxN2dNa2ZnVjhsL0U5eTZQYlNtRkc3MUk4OEt3VGx5SUhEMGlWVytGRlVYQzhzdlRTN3RQWWRPc1AKRUtsaHlkYk9EQ3RRU1d6YjkwK0piMUlpbTNCdXJkdVpBaDIwdnFyVFU2Nnp6RndZSytEczZ1aGRnVW8yTG9qLwpQaUJ1TUxTVmEwM3BWZEgvYVN6ZXI3TGV5eVdrNmFTVGMwNTNNbXFlYWFyanBaTUlpUFpOMmI3TEFnTUJBQUdqCllEQmVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQWRCZ05WSFNVRUZqQVVCZ2dyQmdFRkJRY0RBUVlJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JRdUFwQ3oxdTh5M0w4QlYzdjNwQkg5Mjg4ZgpjakFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBUVFNNVBYNnpuK3JDNEY2S0M2NlBqWGhXRG5oSnJ3OXZPQkxOCkZ2UEoyN3RLd2RYN1NETk5hbGp4eDlGZnh0dFNDZjdMVHNYRGdMdlpCVXNDbXhKNXQxQnp0RmkybjVmM3U3Y24Kd2NjVk51K1YrenU0MU9ROXhzRUhmR3JNb2ptbHl1UHdRUTBac3dKc2JEWXRVSlRvVlExNUg1RlFCak9lOTN6VgpXNitjWWtrLzY2UEVQeklaMUhuWDNydU80bkE2NUk0WC9uR0FkdUx5YVAxZ3VlTkY0UzJhdUtTeUNHOEtnSVdwCkZQUzlEL1VLdHFNMHFmRnZ0K1pNL3BVTU01SGtTL2o0T3FQSVZaN1NhTWRUYWdndVNqYkNITEkrRXl2VEZSNG0KNG5SaDgvbFJHbE1NUTQrZTZEK2NadHN6QWtWSW10Q1c5bncxL2tIdm5HRU9XN015R1E9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg"
}

## Cert-manager

variable "namespace_name" {
  default = "cert-manager"
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
  type = list(string)
  default = [
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

variable "certificates" {
  description = "List of Certificates"
  type        = any
  default     = {}
}

### Istio
variable "atomic" {
  default     = true
  description = "Purge the chart on a failed installation. Default's to \"true\"."
  type        = bool
}

variable "cleanup_on_fail" {
  default     = true
  description = "Allow deletion of new resources created in this upgrade when upgrade fails."
  type        = bool
}

variable "timeout" {
  default     = 360
  description = "Time in seconds to wait for any individual kubernetes operation."
  type        = number
}

### Istio Settings
variable "create_istio_system_namespace" {
  default     = true
  description = "Create a namespace where istio components will be installed."
  type        = bool
}

variable "create_istio_operator_namespace" {
  default     = true
  description = "Create a namespace where istio operator will be installed."
  type        = bool
}

variable "enable_istio_operator" {
  default     = true
  description = "Enables the Istio Operator for installation. Can be disabled if you only need to install Kiali."
  type        = bool
}

variable "istio_chart_name" {
  default     = "istio-operator"
  description = "The name of the Helm chart to install."
  type        = string
}

variable "istio_chart_repository" {
  default     = "https://stevehipwell.github.io/helm-charts/"
  description = "The repository containing the Helm chart to install."
  type        = string
}

variable "istio_chart_version" {
  default     = "2.7.1"
  description = "The version of the Helm chart to install. See https://github.com/stevehipwell/helm-charts/tree/master/charts/istio-operator for available versions."
  type        = string
}

variable "istio_cluster_name" {
  default     = "minikube"
  description = "The name of the kubernetes cluster where Istio is being installed."
  type        = string
}

variable "istio_ingress_gateway_service_annotations" {
  default     = null
  description = "Kubernetes annotations to add to the Istio IngressGateway Service."
  type        = map(string)
}

variable "istio_mesh_id" {
  default     = "1"
  description = "The ID used by the Istio mesh. This is also the ID of the StreamNative Cloud Pool used for the workload environment."
  type        = string
}

variable "istio_network" {
  default     = "network1"
  description = "The network used for the Istio mesh."
  type        = string
}

variable "istio_gateway_certificate_name" {
  default     = "null"
  description = "The certificate name for Istio gateway TLS."
  type        = string
}

variable "istio_gateway_certificate_hosts" {
  default     = ["istio.local"]
  description = "The certificate host(s) for the Istio gateway TLS certificate."
  type        = list(string)
}

variable "istio_gateway_certificate_issuer" {
  default     = null
  description = "The certificate issuer for the Istio gateway TLS certificate."
  type = object({
    group = string
    kind  = string
    name  = string
  })
}

variable "istio_operator_namespace" {
  default     = null
  description = "The namespace where the Istio Operator is installed."
  type        = string
}

variable "istio_profile" {
  default     = "default"
  description = "The path or name for an Istio profile to load. Set to the profile \"default\" if not specified."
  type        = string
}

variable "istio_release_name" {
  default     = "istio-gateway"
  description = "The name of the Istio release"
  type        = string
}

variable "istio_revision_tag" {
  default     = "istio.io/rev"
  description = "The revision tag value use for the Istio label \"istio.io/rev\"."
  type        = string
}

variable "istio_settings" {
  default     = null
  description = "Additional settings which will be passed to the Helm chart values."
  type        = map(any)
}

variable "istio_system_namespace" {
  default     = "istio"
  description = "The namespace used for the Istio components."
  type        = string
}

variable "istio_trust_domain" {
  default     = "istio.local"
  description = "The trust domain used by Istio, which corresponds to the the trust root of a system."
  type        = string
}

variable "istio_values" {
  default     = null
  description = "A list of values in raw YAML to be applied to the helm release. Merges with the settings input, can also be used with the `file()` function, i.e. `file(\"my/values.yaml\")`."
}

### Kiali Settings

variable "create_kiali_cr" {
  default     = null
  description = "Create a Kiali CR for the Kiali deployment. Defaults to \"true\"."
  type        = bool
}

variable "create_kiali_operator_namespace" {
  default     = null
  description = "Create a namespace for the deployment. Defaults to \"true\"."
  type        = bool
}

variable "enable_kiali_operator" {
  default     = true
  description = "Enables the Kiali Operator for installation. Can be disabled if you only need to install Istio."
  type        = bool
}

variable "kiali_operator_chart_name" {
  default     = null
  description = "The name of the Helm chart to install."
  type        = string
}

variable "kiali_operator_chart_repository" {
  default     = null
  description = "The repository containing the Helm chart to install."
  type        = string
}

variable "kiali_operator_chart_version" {
  default     = null
  description = "The version of the Helm chart to install. See https://github.com/kiali/helm-charts/tree/v1.42/kiali-operator for configuration options, and note that newer versions will be in their corresponding branch in the git repo."
  type        = string
}

variable "kiali_operator_namespace" {
  default     = null
  description = "The namespace used for the Kiali operator."
  type        = string
}

variable "kiali_operator_release_name" {
  default     = null
  description = "The name of the Kiali release."
  type        = string
}

variable "kiali_operator_settings" {
  default     = null
  description = "Additional settings which will be passed to the Helm chart values. See https://github.com/kiali/helm-charts/blob/v1.42/kiali-operator/values.yaml for available options."
  type        = map(any)
}

variable "kiali_operator_values" {
  default     = null
  description = "A list of values in raw YAML to be applied to the helm release. Merges with the settings input, can also be used with the `file()` function, i.e. `file(\"my/values.yaml\")`."
}

variable "kiali_gateway_hosts" {
  default     = []
  description = "The external FQDN(s) to expose Kiali on"
  type        = list(string)
}

variable "kiali_gateway_tls_secret" {
  default     = null
  description = "The name of the TLS secret to use at the gateway.  The secret must be located in the Istio gateway's namespace."
  type        = string
}

variable "kiali_namespace" {
  default     = null
  description = "The namespace used for the Kiali CR."
  type        = string
}

variable "kiali_release_name" {
  default     = null
  description = "The name of the Kiali release."
  type        = string
}

variable "kiali_values" {
  default     = null
  description = "A list of values in raw YAML to be applied to the helm release. Merges with the settings input, can also be used with the `file()` function, i.e. `file(\"my/values.yaml\")`."
}
### Top-level Variables

### Networking
#######

variable "service_domain" {
  default     = null
  description = "The DNS domain for external service endpoints. This must be set when enabling Istio or else the deployment will fail."
  type        = string
}
