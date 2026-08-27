locals {
  tags = merge(var.tags, { module = "iam" })
}

# --- GitHub OIDC provider ---
# GitHub ROTA sus llaves de firma (JWKS). Si OIDC falla con
# "Not authorized to perform sts:AssumeRoleWithWebIdentity", actualizar
# github_oidc_thumbprints con los thumbprints de https://token.actions.githubusercontent.com/.well-known/jwks
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

# --- Trust policy: repo -> asume role via web identity ---
data "aws_iam_policy_document" "github_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # GitHub cambió el formato del claim "sub" (ahora incluye @owner_id y @repo_id).
    # NOTA: AWS NO soporta filtrar por "repository" / "repository_owner" en GitHub OIDC
    # (service limitation, aws-actions/configure-aws-credentials#306): esos claims se
    # ignoran al evaluar la trust policy y convierten la condición en "nunca pasa".
    # El repo se restringe correctamente vía "sub".
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${split("/", var.github_repo)[0]}@*/*:*"]
    }
  }
}

# --- Role de GitHub Actions (CI/CD sobre AWS) ---
resource "aws_iam_role" "github_actions" {
  name               = "${var.name_prefix}-github-actions-cloudops"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = merge(local.tags, { Name = "${var.name_prefix}-github-actions-cloudops" })
}

resource "aws_iam_policy" "github_actions" {
  name   = "${var.name_prefix}-github-actions"
  policy = data.aws_iam_policy_document.github_actions.json
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# --- Role de ArgoCD / GitOps (desplegar en EKS) ---
resource "aws_iam_role" "gitops" {
  name               = "${var.name_prefix}-gitops"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = merge(local.tags, { Name = "${var.name_prefix}-gitops" })
}

resource "aws_iam_policy" "gitops" {
  name   = "${var.name_prefix}-gitops"
  policy = data.aws_iam_policy_document.gitops.json
}

data "aws_iam_policy_document" "gitops" {
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:AccessKubernetesApi",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "gitops" {
  role       = aws_iam_role.gitops.name
  policy_arn = aws_iam_policy.gitops.arn
}