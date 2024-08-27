resource "aws_iam_openid_connect_provider" "oidc_git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    IAC = "True"
  }

  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c"]
}

resource "aws_iam_role" "tf-role" {
  name = "tf-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : "arn:aws:iam::908027382789:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
            "token.actions.githubusercontent.com:sub" = ["repo:sousa-v/sousav-ci-iac:ref:refs/heads/main"]
          }
        }
      }
    ]
  })

  inline_policy {
    name = "tf-permission"

    policy = jsonencode({
      Statement = [
        {
          Sid      = "Statement1",
          Action   = "ecr:*",
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Sid      = "Statement2",
          Action   = "iam:*",
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "Statement1",
        Effect : "Allow",
        Principal : {
          Service : "build.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : "arn:aws:iam::908027382789:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
            "token.actions.githubusercontent.com:sub" = ["repo:sousa-v/sousav-cl-api:ref:refs/heads/main"]
          }
        }
      }
    ]
  })

  inline_policy {
    name = "ecr-app-permission"

    policy = jsonencode({
      Statement = [
        {
          Sid      = "Statement1",
          Action   = "apprunner:*",
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Sid = "Statement2",
          Action = [
            "iam:PassRole",
            "iam:CreateServiceLinkedRole"
          ],
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Sid = "Statement3"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    IAC = "True"
  }
}