#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#	Terraform
#
#	Find latest ami for:
#	Ubuntu 20.04
#	Windows Server 2016 Core
#	Amazon Linux2
#
#	Made by JJ
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

provider "aws" {}

data "aws_ami" "latest_ubuntu" {

  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

}

data "aws_ami" "latest_windows" {

  most_recent      = true
  owners           = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

}

data "aws_ami" "latest_amazonlinux2" {

  most_recent      = true
  owners           = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

}

resource "aws_instance" "web_ubuntu" {
	ami= data.aws_ami.latest_ubuntu.id
	instance_type="t2.micro"
	
}

output "latest_ubuntu_id" {
	value = data.aws_ami.latest_ubuntu.id
}
output "latest_ubuntu_name" {
	value = data.aws_ami.latest_ubuntu.name
}


output "latest_windows_id" {
	value = data.aws_ami.latest_windows.id
}
output "latest_windows_name" {
	value = data.aws_ami.latest_windows.name
}


output "latest_amazonlinux2_id" {
	value = data.aws_ami.latest_amazonlinux2.id
}
output "latest_amazonlinux2_name" {
	value = data.aws_ami.latest_amazonlinux2.name
}