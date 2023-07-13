terraform {
  backend "s3" {
    bucket = "terraform-irobo"
    key = "irobo/dev/terraform.tfstate"
    region = "us-east-1"
  }
}