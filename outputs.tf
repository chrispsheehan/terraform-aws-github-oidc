output "branch-specific-defined-roles" {
  description = "CI defined actions role for specified branch"
  value       = module.repos.branch-specific-defined-role
}

output "branch-agnositic-readonly-roles" {
  description = "CI readonly role for all brnaches"
  value       = module.repos.branch-agnositic-readonly-role
}
