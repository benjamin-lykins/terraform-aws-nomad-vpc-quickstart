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
  region = var.primary_aws_region
}

variable "primary_aws_region" {
  description = "AWS region to deploy resources in. "
  type        = string
  default     = "us-east-2"
}

// Using AWS 6.0+ provider features to only define
// a single provider and pass region to modules.
variable "region_configs" {
  type = map(object({
    cidr_block           = string
    private_subnet_cidrs = list(string)
    public_subnet_cidrs  = list(string)
  }))
  default = {
    us-east-2 = {
      cidr_block           = "10.1.0.0/16"
      private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
      public_subnet_cidrs  = ["10.1.3.0/24", "10.1.4.0/24"]
    }
  }
}

module "nomad_vpc" {
  source               = "../.."
  aws_region           = var.primary_aws_region
  vpc_cidr             = var.region_configs["us-east-2"].cidr_block
  private_subnet_cidrs = var.region_configs["us-east-2"].private_subnet_cidrs
  public_subnet_cidrs  = var.region_configs["us-east-2"].public_subnet_cidrs
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
