locals {
  # minimal access required to init and validate terraform
  terraform-init-actions = [
    "s3:GetObject",
    "s3:ListBucket"
  ]

  full-repo-refs = [for r in var.repo-refs : "repo:${var.repo}:ref:refs/${r}"]
}
