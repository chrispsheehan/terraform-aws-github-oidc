resource "aws_iam_role" "this" {
  name               = var.role-name
  description        = "GitHub Actions AWS role for ${var.role-name}"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name   = "${var.role-name}-role-policy"
  policy = data.aws_iam_policy_document.this.json
}
