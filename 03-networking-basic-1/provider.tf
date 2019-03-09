provider "aws" {
  version = "~> 1.0"
  region  = "us-west-2"
  profile = "scale"
}

terraform {
  backend "s3" {
    bucket         = "tflab-terraform-statelock-416373849276"
    key            = "terraform-lab/networking"
    region         = "us-west-2"
    profile        = "scale"
    encrypt        = true
    dynamodb_table = "tflab-terraform-statelock"
  }
}
