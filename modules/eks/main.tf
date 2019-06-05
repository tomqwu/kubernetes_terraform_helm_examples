data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Tier = "private"
  }
}

locals {
  merged_ingress_sg_cidrs = [
    "${data.aws_vpc.selected.cidr_block}",
    "${var.ingress_sg_cidrs}",
  ]

  cluster_name = "${var.app_name}-${var.env_name}-cluster"

  node_name = "${var.app_name}-${var.env_name}-node"
}

provider "kubernetes" {
  host = "${aws_eks_cluster.cluster.endpoint}"

  cluster_ca_certificate = "${base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)}"
}
