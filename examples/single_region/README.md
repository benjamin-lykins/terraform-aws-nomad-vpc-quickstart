This example demonstrates deploying the Nomad VPC Quickstart in a single AWS region, with user configuration. 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nomad_vpc"></a> [nomad\_vpc](#module\_nomad\_vpc) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_primary_aws_region"></a> [primary\_aws\_region](#input\_primary\_aws\_region) | AWS region to deploy resources in. | `string` | `"us-east-2"` | no |
| <a name="input_region_configs"></a> [region\_configs](#input\_region\_configs) | Using AWS 6.0+ provider features to only define a single provider and pass region to modules. | <pre>map(object({<br/>    cidr_block           = string<br/>    private_subnet_cidrs = list(string)<br/>    public_subnet_cidrs  = list(string)<br/>  }))</pre> | <pre>{<br/>  "us-east-2": {<br/>    "cidr_block": "10.1.0.0/16",<br/>    "private_subnet_cidrs": [<br/>      "10.1.1.0/24",<br/>      "10.1.2.0/24"<br/>    ],<br/>    "public_subnet_cidrs": [<br/>      "10.1.3.0/24",<br/>      "10.1.4.0/24"<br/>    ]<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | List of public subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->