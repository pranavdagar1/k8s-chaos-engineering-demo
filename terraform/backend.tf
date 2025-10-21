terraform {
  backend "s3" {
    bucket = "my-new-terraform-bucket-12345"
    key    = "eks/terraform.tfstate"
    region = "eu-north-1"
  }
}
