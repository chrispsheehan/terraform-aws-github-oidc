data "aws_iam_openid_connect_provider" "github" {
  url = "https://${var.github-oidc-domain}"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = concat(local.gha-actions, var.actions)
  }
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = local.gha-actions

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
