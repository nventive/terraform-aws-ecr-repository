module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.35.0"

  use_fullname               = true
  principals_full_access     = [module.ecr_pull_push_role.arn]
  principals_readonly_access = [module.ecr_pull_role.arn]
  image_tag_mutability       = var.image_tag_mutability
  protected_tags             = var.protected_tags
  max_image_count            = var.max_image_count

  context = module.this.context
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_pull_policy" {
  statement {
    sid       = "AllowPullFromECR"
    effect    = "Allow"
    actions   = ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"]
    resources = [module.ecr.repository_arn]
  }

  statement {
    sid       = "AllowGetAuthTokenECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

module "ecr_pull_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.17.0"

  policy_description = "Allow to pull from ${module.this.stage} ECR repository."
  role_description   = "IAM role with pull permissions on ECR ${module.this.stage}."

  policy_documents    = [data.aws_iam_policy_document.ecr_pull_policy.json]
  assume_role_actions = ["sts:AssumeRole"]

  principals = {
    AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  }

  context    = module.this.context
  attributes = ["pull"]
}

data "aws_iam_policy_document" "ecr_push_policy" {
  statement {
    sid    = "AllowFullFromECR"
    effect = "Allow"
    actions = [
      "ecr:UntagResource",
      "ecr:CompleteLayerUpload",
      "ecr:TagResource",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage"
    ]
    resources = [module.ecr.repository_arn]
  }

  statement {
    sid       = "AllowGetAuthTokenECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

module "ecr_pull_push_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.17.0"

  policy_description = "Allow to full access ${module.this.stage} ECR repository."
  role_description   = "IAM role with full permissions on ECR ${module.this.stage}."

  policy_documents = [
    data.aws_iam_policy_document.ecr_pull_policy.json,
    data.aws_iam_policy_document.ecr_push_policy.json
  ]
  assume_role_actions = ["sts:AssumeRole"]

  principals = {
    AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  }

  context    = module.this.context
  attributes = ["pull-push"]
}
