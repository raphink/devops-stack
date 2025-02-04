data "aws_route53_zone" "this" {
  name = var.base_domain
}

data "aws_region" "current" {}

module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  number_of_role_policy_arns    = 1
  role_name                     = format("cert-manager-%s", var.cluster_name)
  provider_url                  = replace(module.cluster.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}

resource "aws_iam_policy" "cert_manager" {
  name_prefix = "cert-manager"
  description = "EKS cert-manager policy for cluster ${module.cluster.cluster_id}"
  policy      = data.aws_iam_policy_document.cert_manager.json
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions = [
      "route53:ListHostedZonesByName"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      format("arn:aws:route53:::hostedzone/%s", data.aws_route53_zone.this.id)
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "route53:GetChange"
    ]

    resources = [
      "arn:aws:route53:::change/*"
    ]

    effect = "Allow"
  }
}
