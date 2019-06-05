data "helm_repository" "private_charts_repo" {
  count = "${var.enable_chartmuseum && var.enable_private_charts_repo ? 1 : 0}"

  name = "private"
  url  = "${var.private_helm_charts_repo_url}"

  depends_on = ["null_resource.default-helmconfig"]
}

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "http://storage.googleapis.com/kubernetes-charts-incubator"

  depends_on = ["null_resource.default-helmconfig"]
}
