variable "github-oidc-domain" {
  type = string
  description = "OIDC domain i.e. token.actions.githubusercontent.com"
}

variable "repo" {
  type        = string
  description = "The target repo for OIDC access i.e octo-org/octo-repo"
}

variable "branch" {
  type        = string
  description = "The target branch for OIDC access i.e main or master"
  default     = "main"
}

variable "branch-actions" {
  type        = list(string)
  description = "The action(s) to be allowed i.e. [dynamodb:*]"
}

variable "resources" {
  type        = list(string)
  description = "The resource(s) to be allowed"
  default     = ["*"]
}

variable "role-name-base" {
  type        = string
  description = "The role base to from role names to use in GHA pipelines"
}
