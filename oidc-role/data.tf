data "aws_iam_openid_connect_provider" "github" {
  url = "https://${var.github-oidc-domain}"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = var.actions
    resources = var.resources
  }
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = var.actions

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.github-oidc-domain}:aud"

      values = data.aws_iam_openid_connect_provider.github.client_id_list
    }

    condition {
      test     = "StringLike"
      variable = "${var.github-oidc-domain}:sub"

      values = ["repo:${var.repo-ref}"]
    }
  }
}
