locals {
  # access required to assume role in github actions
  gha-actions = [
    "sts:AssumeRoleWithWebIdentity",
    "sts:TagSession"
  ]
}
