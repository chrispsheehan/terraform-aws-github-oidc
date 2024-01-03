locals {
  # enable gha roles in ci
  gha-actions = [
    "sts:AssumeRoleWithWebIdentity",
    "sts:TagSession"
  ]
  # minimal access required to init and validate terraform
  terraform-init-actions = concat(local.gha-actions, [
    "s3:GetObject",
    "s3:ListBucket"
  ])
}
