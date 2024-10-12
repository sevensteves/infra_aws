terraform {
  backend "s3" {
    bucket         = "sevensteves-terraform-state-bucket"
    key            = "terraform/state/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "sevensteves-terraform-lock-table"
  }
}
