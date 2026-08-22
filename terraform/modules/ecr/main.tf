resource "aws_ecr_repository" "frontend" {
  name                 = "cloudops-gym-frontend-${var.environment}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "cloudops-gym-frontend-${var.environment}" }
}

resource "aws_ecr_repository" "api" {
  name                 = "cloudops-gym-api-${var.environment}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "cloudops-gym-api-${var.environment}" }
}

resource "aws_ecr_repository" "worker" {
  name                 = "cloudops-gym-worker-${var.environment}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "cloudops-gym-worker-${var.environment}" }
}

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name
  policy     = jsonencode({ rules = [{ rulePriority = 1, description = "keep last 5", selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 5 }, action = { type = "expire" } }] })
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy     = jsonencode({ rules = [{ rulePriority = 1, description = "keep last 5", selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 5 }, action = { type = "expire" } }] })
}

resource "aws_ecr_lifecycle_policy" "worker" {
  repository = aws_ecr_repository.worker.name
  policy     = jsonencode({ rules = [{ rulePriority = 1, description = "keep last 5", selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 5 }, action = { type = "expire" } }] })
}
