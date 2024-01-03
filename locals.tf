locals {
  # minimal access required to init and validate terraform
  terraform-init-actions = [
    "s3:GetObject",
    "s3:ListBucket"
  ]
}
