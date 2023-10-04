terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    # 良しなに変更
    bucket  = "u1aryz-terraform-state"
    key     = "ssm-test.state"
    region  = "ap-northeast-1"
    profile = "u1aryz"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "u1aryz"
}
