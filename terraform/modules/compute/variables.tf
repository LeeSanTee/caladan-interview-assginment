variable "aws_profile" {
  type        = string
  description = "aws profile"
}

variable "aws_region" {
  type        = string
  description = "aws region"
}

variable "team_name" {
  type        = string
  description = "owner of the resource"
}

variable "project_name" {
  type        = string
  description = "project name, eg. my-website"
}

variable "environment_name" {
  type        = string
  description = "environment, eg. prod, staging, dev"
}

variable "ami_prefix" {
  type        = string
  description = "prefix of the name of the ami that should be launched"
}

variable "subnet_prefix" {
  type        = string
  description = "prefix of the name of the subnet that should be launched"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
}

variable "ssh_key_name" {
  type        = string
  description = "ec2 ssh key"
}

variable "vpc_name" {
    type        = string
    default     = "main"
    description = "the vpc name"
}

variable "user_data" {
    type        = string
    default     = ""
    description = "User data to provide when launching the instance"
}

variable "user_data_replace_on_change" {
    type        = bool
    default     = false
    description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate of the EC2 instance when set to true. Defaults to false if not set."
}

variable "enable_eip" {
    type        = bool
    default     = false
    description = "Enable public EIP attachment to instance"
}