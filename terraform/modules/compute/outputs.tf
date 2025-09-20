output "instance_id" {
  value = aws_instance.packer_node_instance.id
}

output "private_dns" {
  value = aws_instance.packer_node_instance.private_dns
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.default.cidr_block
}

output "ami_id" {
  value = data.aws_ami.packer_node_ami.id
}

output "subnet_id" {
  value = random_shuffle.subnet_id.result[0]
}

output "public_dns" {
  value = var.enable_eip ? aws_eip.packer_node_instance[0].public_dns : "null"
}

output "public_ip" {
  value = var.enable_eip ? aws_eip.packer_node_instance[0].public_ip : "null"
}