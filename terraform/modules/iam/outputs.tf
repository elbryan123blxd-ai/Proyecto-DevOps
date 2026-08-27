output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  value = aws_iam_role.github_actions.name
}

output "gitops_role_arn" {
  value = aws_iam_role.gitops.arn
}