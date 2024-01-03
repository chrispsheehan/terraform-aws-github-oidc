module "terraform_validate_role" {
  source = "./oidc-role"

  role-name          = "${var.role-name-base}-gha-validate-role"
  actions            = local.terraform-init-actions
  resources          = var.resources
  repo-ref           = "${var.repo}:*"
  github-oidc-domain = var.github-oidc-domain
}

module "terraform_branch_deploy_role" {
  source = "./oidc-role"

  role-name          = "${var.role-name-base}-gha-deploy-branch-role"
  actions            = concat(local.terraform-init-actions, var.branch_actions)
  resources          = var.resources
  repo-ref           = "${var.repo}:ref:refs/heads/${var.branch}"
  github-oidc-domain = var.github-oidc-domain
}
