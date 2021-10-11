provider "aws" {}


data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "current" {}
data "aws_vpc" "myvpc" {
  tags = {
    Name = "test3"
  }

}

resource "aws_subnet" "my_subnet" {
  vpc_id = data.aws_vpc.myvpc.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block = "10.10.1.0/24"
  tags = {
    Name = "Subnet-1 in ${data.aws_availability_zones.working.names[0]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region=data.aws_region.current.description
  }
  
}

#~~~~~~~~~~~~~~~~~~Outputs~~~~~~~~~~~~~~~~~

output "my_vpc_tag_test3_id" {
  value = data.aws_vpc.myvpc.id
}

output "my_vpc_tag_test3_cidr" {
  value = data.aws_vpc.myvpc.cidr_block
}

output "data_aws_availability_zones" {
  value= data.aws_availability_zones.working.names
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = data.aws_region.current.name
}
output "region_descr" {
  value = data.aws_region.current.description
}

output "vpcs" {
  value = data.aws_vpcs.current.ids
}