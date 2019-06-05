variable "env_name" {}

variable "vpc_name" {}
variable "aws_eks_cluster_endpoint" {}
variable "aws_eks_cluster_certificate_authority_data" {}

variable "aws_eks_cluster_name" {}

#########
# helm 
#########

variable "aws_profile" {}

variable "private_helm_charts_repo_url" {
  default = "https://charts.devopsify.io"
}

variable "helm_service_account_name" {
  default = "tiller"
}

variable "helm_home" {
  description = "absoluate path of helm home"
  default     = "./.helm"
}

variable "tiller_namespace" {
  default = "kube-system"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.0"
}

######################
# kube2iam release
######################
variable "kube2iam_default_role_name" {
  default = "kube2iam-default"
}

variable "kube2iam_base_role_arn" {
  description = "kube2iam role to use for instance profile role of worker node"
}

########################
# external-dns release
########################
variable "external_dns_assume_role_arn" {
  description = "external-dns uses this role to set route53 dns record"
}

variable "external_dns_domain_filters" {
  default = "devopsify.io"
}

variable "external_dns_txt_owner_id" {
  description = "when using the TXT registry, a name that identifies this instance of ExternalDNS"
}

variable "external_dns_aws_zonetype" {
  default     = "private"
  description = "filter for zones of this type from public, private"
}

variable "external_dns_log_level" {
  default = "info"
}

#######################################
# aws alb ingress controller release
#######################################
variable "aws_alb_ingress_controller_pod_annotations_role" {
  description = "role that used to allowing alb ingress pod to assume to provision the alb"
}

###############################
# chartmuseum release
###############################
variable "chartmuseum_s3_svc_role" {}

variable "chartmuseum_s3_bucket_name" {}

variable "chartmuseum_s3_region" {
  default = "us-east-1"
}

variable "chartmuseum_enable_debug" {
  default = "false"
}

variable "chartmuseum_allow_overwrite" {
  default = "true"
}

variable "chartmuseum_host_name" {
  default = "charts.devopsify.io"
}

########################
# helm feature flags
########################
variable "enable_default_kubeconfig" {
  default = false
}

variable "enable_default_helmconfig" {
  default = false
}

variable "enable_dashboard" {
  default = true
}

variable "enable_nginx_ingress" {
  default = false
}

variable "enable_kube2iam" {
  default = true
}

variable "enable_external_dns" {
  default = true
}

variable "enable_aws_alb_ingress_controller" {
  default = false
}

variable "enable_chartmuseum" {
  default = false
}

variable "enable_private_charts_repo" {
  default = false
}

######################################
# aws *.devopsify.io acm domain name
######################################
variable "alb_ingress_ssl_acm_cert_domain_name" {
  default = "*.devopsify.io"
}

variable "aws_alb_ingress_cidr" {
  default = ["10.0.0.0/16"]
  type    = "list"
}
