terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-configurable-number-of-vms"
  #   region = "us-east-1"
  #   key    = "terraform.tfstate"
  # }
}
