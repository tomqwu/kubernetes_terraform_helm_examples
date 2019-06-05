resource "aws_security_group" "cluster" {
  name        = "${local.cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${data.aws_vpc.selected.id}"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.cluster_name}"
  }
}

# Allow inbound traffic from your local workstation external IP
# to the Kubernetes. 
resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.cluster.id}"
  to_port           = 443
  type              = "ingress"

  cidr_blocks = [
    "${local.merged_ingress_sg_cidrs}",
  ]
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 443
  type                     = "ingress"
}
