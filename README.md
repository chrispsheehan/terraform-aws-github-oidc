# terraform-aws-github-oidc

This module creates OIDC roles to be used in terraform related Github Actions.

The below will create two iam roles for `octo-org/octo-repo` (replace with your repo);

- `octo-org-oidc-gha-validate-role`
- `octo-org-oidc-gha-deploy-branch-role`

## terraform usage

```terraform
locals {
  github_oidc_domain = "token.actions.githubusercontent.com"
}

<!-- REQUIRED create aws openid provider -->
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://${local.local.github_oidc_domain}"
  client_id_list  = ["token.actions.githubusercontent.com"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}

module "example-oidc-roles" {
  depends_on = [aws_iam_openid_connect_provider.github]

  source = "github.com/chrispsheehan/terraform-aws-github-oidc"

  github-oidc-domain = local.github_oidc_domain
  role-name-base     = "octo-org-oidc-example"
  repo               = "octo-org/octo-repo"
  branch             = "main"
  branch_actions     = ["sts:GetCallerIdentity"]
}

output "branch-specific-defined-role" {
  description = "CI defined actions role for specified branch"
  value       = module.example-oidc-roles.branch-specific-defined-role
}

output "branch-agnostic-validate-role" {
  description = "CI readonly role for all branches"
  value       = module.example-oidc-roles.branch-agnostic-validate-role
}
```

## Terraform init and validate

- Any branch can run the below jobs.

```yaml
name: Branch Check
on:
  push:
    branches-ignore:
      - main

env:
  AWS_REGION: ${{ vars.AWS_REGION }}
  AWS_ACCOUNT_ID: ${{ vars.AWS_ACCOUNT_ID }}

jobs:
  terraform-init-validate:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          role-to-assume: arn:aws:iam::${{ env.AWS_ACCOUNT_ID }}:role/octo-oidc-gha-validate-role
          role-session-name: GitHubActions

      - name: Proof of concept terraform Init
        run: |
          cd tf
          terraform init

      - name: Proof of concept terraform Validate
        run: |
          cd tf
          terraform validate

```

## Terraform defined branch and actions 

- In this case we only allow `sts:GetCallerIdentity` as a proof of concept. Any other calls are blocked.
  - This can of course be extended by adding scopes to `branch_actions` (above) to enable `plan`, `apply` and `destroy` jobs.
- Only `main` can execute the below. All other branches are blocked.

```yaml
name: Defined actions
on:
  push:
    branches-ignore:
      - main

env:
  AWS_REGION: ${{ vars.AWS_REGION }}
  AWS_ACCOUNT_ID: ${{ vars.AWS_ACCOUNT_ID }}

jobs:
  terraform-defined-actions:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          role-to-assume: arn:aws:iam::${{ env.AWS_ACCOUNT_ID }}:role/octo-org-oidc-gha-deploy-branch-role
          role-session-name: GitHubActions

      - run: aws sts get-caller-identity

```