output "branch-specific-defined-role" {
  description = "Github action role to run only defined actions (terraform deploy) for the specified branch"
  value       = module.terraform_deploy_role.oidc-role-name
}

output "branch-agnostic-validate-role" {
  description = "Github action role to run terraform init/validate for all branches"
  value       = module.terraform_validate_role.oidc-role-name
}
