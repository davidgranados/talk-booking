terraform {
    backend "http" {
    }

    required_providers {
        aws = ">= 5.0, < 6.0"
    }
}

provider "aws" {
    region = var.region
}
