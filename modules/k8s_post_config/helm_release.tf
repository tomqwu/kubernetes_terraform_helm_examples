##########################
# namespace: kube-system
##########################

resource "helm_release" "kubernetes-dashboard" {
  count = "${var.enable_dashboard ? 1 : 0}"

  name      = "kubernetes-dashboard"
  chart     = "stable/kubernetes-dashboard"
  namespace = "kube-system"

  set {
    name  = "resources.limits.cpu"
    value = "200m"
  }
}

resource "helm_release" "kube2iam" {
  count = "${var.enable_kube2iam ? 1 : 0}"

  name      = "kube2iam"
  chart     = "stable/kube2iam"
  namespace = "kube-system"

  set {
    name  = "extraArgs.base-role-arn"
    value = "${var.kube2iam_base_role_arn}"
  }

  set {
    name  = "extraArgs.default-role"
    value = "${var.kube2iam_default_role_name}"
  }

  set {
    name  = "host.iptables"
    value = "true"
  }

  set {
    name  = "host.interface"
    value = "eni+"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccountName"
    value = "kube2iam"
  }

  set {
    name  = "verbose"
    value = "true"
  }
}

resource "helm_release" "nginx-ingress" {
  count = "${var.enable_nginx_ingress ? 1 : 0}"

  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"

  # set_string {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
  #   value = "0.0.0.0/0"
  # }

  set {
    name  = "rbac.create"
    value = "true"
  }
}

# https://github.com/helm/charts/blob/master/stable/external-dns
resource "helm_release" "external-dns" {
  count = "${var.enable_external_dns ? 1 : 0}"

  name      = "external-dns"
  chart     = "stable/external-dns"
  namespace = "kube-system"

  set {
    name  = "aws.zoneType"
    value = "${var.external_dns_aws_zonetype}"
  }

  set {
    name  = "domainFilters"
    value = "{${var.external_dns_domain_filters}}"
  }

  set {
    name  = "registry"
    value = "txt"
  }

  set {
    name  = "txtOwnerId"
    value = "${var.external_dns_txt_owner_id}"
  }

  set {
    name  = "logLevel"
    value = "${var.external_dns_log_level}"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccountName"
    value = "external-dns"
  }

  set_string {
    name  = "podAnnotations.iam\\.amazonaws\\.com/role"
    value = "${var.external_dns_assume_role_arn}"
  }
}

# https://github.com/helm/charts/tree/master/incubator/aws-alb-ingress-controller
resource "helm_release" "aws-alb-ingress-controller" {
  count = "${var.enable_aws_alb_ingress_controller ? 1 : 0}"

  name       = "aws-alb-ingress-controller"
  chart      = "incubator/aws-alb-ingress-controller"
  repository = "incubator"
  namespace  = "kube-system"

  set_string {
    name  = "podAnnotations.iam\\.amazonaws\\.com/role"
    value = "${var.aws_alb_ingress_controller_pod_annotations_role}"
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }

  set {
    name  = "clusterName"
    value = "${var.aws_eks_cluster_name}"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccountName"
    value = "aws-alb-ingress-controller"
  }
}

data "template_file" "values_chartmuseum_yaml" {
  template = "${file("${path.module}/templates/values_chartmuseum.yaml.tpl")}"

  vars {
    env_name = "${var.env_name}"

    chartmuseum_s3_svc_role     = "${var.chartmuseum_s3_svc_role}"
    chartmuseum_s3_bucket_name  = "${var.chartmuseum_s3_bucket_name}"
    chartmuseum_s3_region       = "${var.chartmuseum_s3_region}"
    chartmuseum_host_name       = "${var.chartmuseum_host_name}"
    chartmuseum_enable_debug    = "${var.chartmuseum_enable_debug}"
    chartmuseum_allow_overwrite = "${var.chartmuseum_allow_overwrite}"

    aws_alb_ingress_cidr    = "${join(",", local.aws_alb_ingress_cidr)}"
    aws_acm_certificate_arn = "${data.aws_acm_certificate.acm.arn}"
  }
}

resource "helm_release" "chartmuseum" {
  count = "${var.enable_chartmuseum ? 1 : 0}"

  name      = "chartmuseum"
  chart     = "stable/chartmuseum"
  namespace = "kube-system"

  values = [
    "${data.template_file.values_chartmuseum_yaml.rendered}",
  ]
}
