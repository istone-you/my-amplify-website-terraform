variable "github_token" {}
variable "github_owner" {}

# Configure the AWS provider
provider "aws" {
  region = "ap-northeast-1"
}

# Configure the GitHub provider
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

# Create a new GitHub repository
resource "github_repository" "website_repo" {
  name        = "my-amplify-website"
  description = "A repository for the Amplify website"
}

# Create an AWS Amplify App
resource "aws_amplify_app" "website_app" {
  name                 = "my-amplify-website"
  iam_service_role_arn = "arn:aws:iam::763397213391:role/amplifyconsole-backend-role"

  repository   = "https://github.com/${var.github_owner}/${github_repository.website_repo.name}"
  access_token = var.github_token

  build_spec = <<-EOT
    version: 1
    backend:
      phases:
        build:
          commands:
            - '# Execute Amplify CLI with the helper script'
            - amplifyPush --simple
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  environment_variables = {
    _CUSTOM_IMAGE = "aws/codebuild/amazonlinux2-x86_64-standard:3.0",
    _LIVE_UPDATES = "[{\"name\":\"Amplify CLI\",\"pkg\":\"@aws-amplify/cli\",\"type\":\"npm\",\"version\":\"latest\"}]"
  }
}

# Create a new amplify branch
resource "aws_amplify_branch" "dev" {
  app_id      = aws_amplify_app.website_app.id
  branch_name = "dev"
}

resource "aws_amplify_branch" "master" {
  app_id      = aws_amplify_app.website_app.id
  branch_name = "master"
  framework   = "React - Amplify"
  stage       = "PRODUCTION"
}

# Associate the domain with the Amplify App
#resource "aws_amplify_domain_association" "website_domain_association" {
#  app_id      = aws_amplify_app.website_app.id
#  domain_name = aws_route53_zone.website_hosted_zone.name
#
#  sub_domain {
#    prefix      = "www"
#    branch_name = aws_amplify_branch.main.branch_name
#  }
#
#}

# Create a new Route53 Hosted Zone
resource "aws_route53_zone" "website_hosted_zone" {
  name = "my-amplify-website.com"
}

# Create a new SNS Topic
resource "aws_sns_topic" "SNSTopic" {
  display_name = "${aws_route53_zone.website_hosted_zone.name}でのお問い合わせ"
  name         = "ContactFormMail"
}

# Create a new SNS Subscription
resource "aws_sns_topic_subscription" "SNSSubscription" {
  topic_arn = aws_sns_topic.SNSTopic.arn
  endpoint  = "ishii@f-logic.jp"
  protocol  = "email"
}
