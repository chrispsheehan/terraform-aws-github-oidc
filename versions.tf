terraform {
  required_version = ">= 1.5.7"
  
  required_providers {
    aws = {
      version = ">= 4.15.0"
      source  = "hashicorp/aws"
    }
  }
}