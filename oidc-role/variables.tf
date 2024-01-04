variable "github-oidc-domain" {
  type = string
}

variable "repo-ref" {
  type        = string
  description = "The target repo / branch for OIDC access i.e octo-org/octo-repo:ref:refs/heads/octo-branch or octo-org/octo-repo"
}

variable "actions" {
  type        = list(string)
  description = "The action(s) to be allowed i.e. [dynamodb:*]"
}

variable "resources" {
  type = list(string)
}

variable "role-name" {
  type        = string
  description = "The role to use in GHA pipelines"
}
