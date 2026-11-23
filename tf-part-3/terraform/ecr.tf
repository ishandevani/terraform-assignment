resource "aws_ecr_repository" "flask" {
  name                 = "${var.project_name}-flask"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "express" {
  name                 = "${var.project_name}-express"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
