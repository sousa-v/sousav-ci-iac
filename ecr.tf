resource "aws_ecr_repository" "sousav-ci-api" {
  name                 = "sousav-ci"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    IAC = "True"
  }
}