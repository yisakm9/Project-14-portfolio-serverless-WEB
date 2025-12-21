terraform {
  backend "s3" {
    bucket       = "yisak-terraform-state-bucket"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}