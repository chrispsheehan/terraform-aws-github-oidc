module "terraform_validate_role" {
  source = "./oidc-role"

  role-name          = "${var.role-name-base}-gha-validate-role"
  actions            = local.terraform-init-actions
  resources          = var.resources
  repo-refs          = ["repo:${var.repo}:*"]
  github-oidc-domain = var.github-oidc-domain
}

module "terraform_deploy_role" {
  source = "./oidc-role"

  role-name          = "${var.role-name-base}-gha-deploy-branch-role"
  actions            = concat(local.terraform-init-actions, var.branch-actions)
  resources          = var.resources
  repo-refs          = local.full-repo-refs
  github-oidc-domain = var.github-oidc-domain
}
