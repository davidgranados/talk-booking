terraform {
    backend "http" {
    }

    required_providers {
        aws = ">= 5.0, < 6.0"
    }
}
