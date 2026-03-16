# S3 backend (fixed configuration)
terraform {
  backend "s3" {
    bucket  = "h-katabami-cicd-state-353666332910"
    key     = "state/cicd-template/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}