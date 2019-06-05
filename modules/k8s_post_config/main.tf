resource "null_resource" "default-kubeconfig" {
  count = "${var.enable_default_kubeconfig ? 1 : 0}"

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "AWS_PROFILE=${var.aws_profile} aws eks update-kubeconfig --name ${var.aws_eks_cluster_name}"
  }
}

# Workaround with bug
# https://github.com/terraform-providers/terraform-provider-helm/pull/185
resource "null_resource" "default-helmconfig" {
  count = "${var.enable_default_helmconfig ? 1 : 0}"

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "helm init --service-account ${var.helm_service_account_name} --client-only --home ${local.helm_home} --tiller-namespace ${var.tiller_namespace}"
  }
}

provider "kubernetes" {
  host = "${var.aws_eks_cluster_endpoint}"

  cluster_ca_certificate = "${base64decode(var.aws_eks_cluster_certificate_authority_data)}"
}

provider "helm" {
  home = "${local.helm_home}"

  install_tiller = false # https://github.com/terraform-providers/terraform-provider-helm/issues/148

  service_account = "${var.helm_service_account_name}"

  kubernetes {
    host = "${var.aws_eks_cluster_endpoint}"

    cluster_ca_certificate = "${base64decode(var.aws_eks_cluster_certificate_authority_data)}"
  }
}

data "aws_acm_certificate" "acm" {
  domain      = "${var.alb_ingress_ssl_acm_cert_domain_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

locals {
  helm_home = "${path.module}/${var.helm_home}"

  aws_alb_ingress_cidr = [
    "${var.aws_alb_ingress_cidr}",
    "${data.aws_vpc.selected.cidr_block}",
  ]
}

data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc_name}"
  }
}
