output "kube2iam-alb-controller-role-arn" {
  value = "${aws_iam_role.alb_controller.arn}"
}
