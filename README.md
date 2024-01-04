# Terraform AWS Github Action OIDC Roles module

This module creates OIDC roles to be used in terraform related Github Actions. More details [here](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

The below will create two iam roles for `octo-org/octo-repo` (replace with your repo);

- `octo-org-oidc-gha-validate-role`
- `octo-org-oidc-gha-deploy-branch-role`

## Usage

Run the below to create the OIDC provider and roles. This can live in it's own repo, separate to the code deployed via Github actions.

*NOTE*: You may have an existing provider; in which case remove `aws_iam_openid_connect_provider.github` or alternatively [import](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider#import).

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

  source  = "chrispsheehan/github-oidc/aws"
  version = "1.0.0"

  github-oidc-domain = local.github_oidc_domain
  role-name-base     = "octo-org-oidc-example"
  repo               = "octo-org/octo-repo"
  branch             = "main"
  branch_actions     = ["dynamodb:*", "s3:*", "cloudfront:*", "wafv2:*", "acm:*", "route53:*"]
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

## Github Actions

### Init and validate

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

### Defined branch deployment

- In the below job we only allow `["dynamodb:*", "s3:*", "cloudfront:*", "wafv2:*", "acm:*", "route53:*"]` actions, as specified above. Any other actions are blocked.
- Only `main` can execute the below. All other branches are blocked.

```yaml
name: Defined branch deploy
on:
  push:
    branches-ignore:
      - main

env:
  AWS_REGION: ${{ vars.AWS_REGION }}
  AWS_ACCOUNT_ID: ${{ vars.AWS_ACCOUNT_ID }}

jobs:
  terraform-deploy:
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

      - run: terraform init
      - run: terraform apply -auto-approve

```