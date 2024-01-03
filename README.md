# terraform-aws-github-oidc

This module creates an OIDC role to be used in Github Actions.

```terraform
locals {
  github_oidc_domain = "token.actions.githubusercontent.com"
}

<!-- create aws openid provider -->
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://${local.local.github_oidc_domain}"
  client_id_list  = ["token.actions.githubusercontent.com"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}

module "oidc-roles" {
  source = "[tbc]"

  github-oidc-domain = local.github_oidc_domain
  role-name-base     = "oidc-example-gha-role"
  repo               = "octo-org/octo-repo"
  branch_actions     = ["sts:GetCallerIdentity"]
}

output "branch-specific-defined-role" {
  description = "CI defined actions role for specified branch"
  value       = module.oidc-roles.branch-specific-defined-role
}

output "branch-agnostic-validate-role" {
  description = "CI readonly role for all branches"
  value       = module.oidc-roles.branch-agnostic-readonly-role
}
```