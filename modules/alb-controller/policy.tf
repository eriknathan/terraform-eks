resource "aws_iam_policy" "eks_controller_policy" {
  name        = "${var.project_name}-aws-load-balancer-controller"
  description = "Policy to Load Balancer"

  policy = file("${path.module}/iam_policy.json")

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-policy-alb-controller"
    }
  )
}