resource "aws_iam_role" "node" {
  name = "${local.node_name}-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_instance_profile" "node" {
  name = "${local.node_name}-instance-profile"
  role = "${aws_iam_role.node.name}"
}

data "aws_iam_policy_document" "kube2iam" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "kube2iam" {
  name   = "${var.app_name}-${var.env_name}-kube2iam"
  policy = "${data.aws_iam_policy_document.kube2iam.json}"
}

resource "aws_iam_role_policy_attachment" "kube2iam" {
  role       = "${aws_iam_role.node.name}"
  policy_arn = "${aws_iam_policy.kube2iam.arn}"
}
