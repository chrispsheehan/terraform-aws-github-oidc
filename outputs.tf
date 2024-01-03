output "branch-specific-defined-role" {
  description = "CI defined actions role for specified branch"
  value       = module.terraform_branch_deploy_role.oidc-role-name
}

output "branch-agnostic-validate-role" {
  description = "CI readonly role for all brnaches"
  value       = module.terraform_validate_role.oidc-role-name
}
