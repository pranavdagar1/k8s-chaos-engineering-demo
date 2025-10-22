terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region

  # Optional: Add default tags for all resources
  default_tags {
    tags = {
      Project     = "Chaos-Kube"
      Environment = "Dev"
    }
  }
}
