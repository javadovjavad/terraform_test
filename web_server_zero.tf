#Terraform writed by JJ
#security group
#launch configuration
#autoscalling group
#classic load balancer

provider "aws" {}

data "aws_availability_zones" "working" {}

data "aws_ami" "latest_amazonlinux2" {

  most_recent      = true
  owners           = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_security_group" "forserver" {
  name        = "Dynamic security group for ubuntu_web"
  description = "Allow inbound traffic"
  
dynamic "ingress"{
  for_each = ["80","443"]
  content {
      description      = "ingress SSH from VPC"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
	    cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false     
  }
}


  egress = [
    {
      description      = "Allow egress from VPC"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false     
    }
  ]

  tags = {
    Name = "Dynamic security group"
  }
}


resource "aws_launch_configuration" "forweb" {
  name          = "WebServer-Highly-Available"
  image_id      = data.aws_ami.latest_amazonlinux2.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.forserver.id]
  user_data=file("user_data.sh")
  lifecycle {
    create_before_destroy=true
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "WebServer-Highly-Available-ASG"
  max_size                  = 2
  min_size                  = 2
  launch_configuration      = aws_launch_configuration.forweb.name
  min_elb_capacity          = 2 
  vpc_zone_identifier       = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]
  health_check_type        = "ELB"
  load_balancers          =[aws_elb.myserver.name]
  

  dynamic "tag" {
    for_each = {
      Name= "Webserver-in-ASG"
      Owner = "JJ"
      
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    
    }
  
  }
  
  lifecycle {
    create_before_destroy=true
  }
  
}

resource "aws_elb" "myserver" {
  name="Webserver-ELB"
  availability_zones = [data.aws_availability_zones.working.names[0],data.aws_availability_zones.working.names[1]]
  security_groups =  [aws_security_group.forserver.id]
  listener {
    lb_port             = 80
    lb_protocol         = "http"
    instance_port       = 80
    instance_protocol   = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            =  10
  }
  tags = {
  Name = "WS-HA-ELB"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.working.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.working.names[1]
}

output "web_load_balancer_url"{
  value = aws_elb.myserver.dns_name
}
