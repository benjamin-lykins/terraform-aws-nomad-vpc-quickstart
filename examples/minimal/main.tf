terraform {
  ## Optional backend configuration with Terraform Cloud. 
  #   cloud {
  #     organization = "myorg"
  #     workspaces {
  #       tags = ["nomad", "vpc"]
  #     }
  #   }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.provider_aws_region
}

variable "provider_aws_region" {
  description = "AWS region to authenticate provider."
  type        = string
  default     = "us-east-2"
}

variable "prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "dev"
}

module "nomad_vpc" {
  source     = "../.."
  aws_region = var.provider_aws_region
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.nomad_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.nomad_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.nomad_vpc.private_subnet_ids
}
