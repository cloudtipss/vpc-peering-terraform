# vpc-peering-terraform
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.22.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2-instance-a"></a> [ec2-instance-a](#module\_ec2-instance-a) | terraform-aws-modules/ec2-instance/aws | 5.5.0 |
| <a name="module_ec2-instance-b"></a> [ec2-instance-b](#module\_ec2-instance-b) | terraform-aws-modules/ec2-instance/aws | 5.5.0 |
| <a name="module_vpc-a"></a> [vpc-a](#module\_vpc-a) | terraform-aws-modules/vpc/aws | 5.1.2 |
| <a name="module_vpc-b"></a> [vpc-b](#module\_vpc-b) | terraform-aws-modules/vpc/aws | 5.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.public_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route.peering_routes-ab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.peering_routes-ba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_security_group.ssh-a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssh-b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_peering_connection.foo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Connect_to_instance"></a> [Connect\_to\_instance](#output\_Connect\_to\_instance) | The public IP address assigned to the instance |
<!-- END_TF_DOCS -->