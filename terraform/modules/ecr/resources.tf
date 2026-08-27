locals {
  tags = merge(var.tags, { module = "ecr" })
}

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = "${var.name_prefix}-${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, { Name = "${var.name_prefix}-${each.value}" })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = <<-EOT
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Mantener ultimas ${var.image_count_to_keep} imagenes",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": ${var.image_count_to_keep}
        },
        "action": { "type": "expire" }
      }
    ]
  }
  EOT
}