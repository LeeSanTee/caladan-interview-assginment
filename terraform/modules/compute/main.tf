data "aws_caller_identity" "current" {}

data "aws_ami" "packer_node_ami" {
  owners      = [data.aws_caller_identity.current.account_id]
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${var.ami_prefix}*"]
  }
}

resource "aws_instance" "packer_node_instance" {
  ami             = data.aws_ami.packer_node_ami.id
  instance_type   = var.instance_type
  key_name        = var.ssh_key_name
  subnet_id       = random_shuffle.subnet_id.result[0]
  
  vpc_security_group_ids = [
    aws_security_group.packer_node_sg.id
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    encrypted             = false
    delete_on_termination = true
  }

  user_data = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  tags = {
    Name = "${var.team_name}-${var.project_name}-${var.environment_name}"
  }
}

resource "aws_eip" "packer_node_instance" {
  count     = var.enable_eip ? 1 : 0 
  domain    = "vpc"
  instance  = aws_instance.packer_node_instance.id
}

resource "aws_security_group" "packer_node_sg" {
  name        = "${var.team_name}-${var.project_name}-${var.environment_name}-ec2-sg"
  description = "security group for server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = "8081"
    to_port     = "8081"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
