This example demonstrates deploying the Nomad VPC Quickstart in multiple AWS regions, with automated VPC peering between them. Make sure CIDRs do not overlap across regions if looking to peer VPCs and federate Nomad clusters.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nomad_vpc"></a> [nomad\_vpc](#module\_nomad\_vpc) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_peering_connection.nomad](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.nomad](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names. | `string` | `"dev"` | no |
| <a name="input_provider_aws_region"></a> [provider\_aws\_region](#input\_provider\_aws\_region) | AWS region to authenticate provider. | `string` | `"us-east-2"` | no |
| <a name="input_region_configs"></a> [region\_configs](#input\_region\_configs) | n/a | <pre>map(object({<br/>    cidr_block           = string<br/>    private_subnet_cidrs = list(string)<br/>    public_subnet_cidrs  = list(string)<br/>  }))</pre> | <pre>{<br/>  "us-east-2": {<br/>    "cidr_block": "10.1.0.0/16",<br/>    "private_subnet_cidrs": [<br/>      "10.1.1.0/24",<br/>      "10.1.2.0/24"<br/>    ],<br/>    "public_subnet_cidrs": [<br/>      "10.1.3.0/24",<br/>      "10.1.4.0/24"<br/>    ]<br/>  },<br/>  "us-west-2": {<br/>    "cidr_block": "10.2.0.0/16",<br/>    "private_subnet_cidrs": [<br/>      "10.2.1.0/24",<br/>      "10.2.2.0/24"<br/>    ],<br/>    "public_subnet_cidrs": [<br/>      "10.2.3.0/24",<br/>      "10.2.4.0/24"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_vpc_peering"></a> [vpc\_peering](#input\_vpc\_peering) | Map of VPC Peering Configurations | <pre>map(object({<br/>    peer_requestor_region = string<br/>    peer_accepter_region  = string<br/>  }))</pre> | <pre>{<br/>  "useast_to_uswest": {<br/>    "peer_accepter_region": "us-west-2",<br/>    "peer_requestor_region": "us-east-2"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Map of region to list of private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Map of region to list of public subnet IDs |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | The IDs of the VPCs |
<!-- END_TF_DOCS -->