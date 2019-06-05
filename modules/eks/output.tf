output "cluster_name" {
  value = "${local.cluster_name}"
}

output "k8s_node_ec2_instance_role_arn" {
  value = "${aws_iam_role.node.arn}"
}

output "endpoint" {
  value = "${aws_eks_cluster.cluster.endpoint}"
}

output "certificate_authority_data" {
  value = "${aws_eks_cluster.cluster.certificate_authority.0.data}"
}
