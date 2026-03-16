# S3 backend (fixed configuration)
terraform {
  backend "s3" {
    bucket  = "h-katabami-cicd-state-237710157750"
    key     = "state/cicd-template/dev/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}