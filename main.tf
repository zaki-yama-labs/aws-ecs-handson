terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_ecr_repository" "service" {
  force_delete         = null
  image_tag_mutability = "MUTABLE"
  name                 = "h4b-ecs-helloworld"
  tags                 = {}
  tags_all             = {}
  encryption_configuration {
    encryption_type = "AES256"
    kms_key         = null
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_vpc" "main" {
  assign_generated_ipv6_cidr_block     = false
  cidr_block                           = "10.0.0.0/16"
  enable_dns_hostnames                 = false
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"
  ipv4_ipam_pool_id                    = null
  ipv4_netmask_length                  = null
  ipv6_cidr_block                      = null
  ipv6_cidr_block_network_border_group = null
  tags = {
    Name = "h4b-ecs-vpc"
  }
  tags_all = {
    Name = "h4b-ecs-vpc"
  }
}

resource "aws_security_group" "elb_sg" {
  description = "default VPC security group"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = null
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "HTTP"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = []
      description      = null
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    }
  ]
  name                   = "default"
  revoke_rules_on_delete = false
  vpc_id                 = aws_vpc.main.id
}

resource "aws_ecs_cluster" "main" {
  name     = "h4b-ecs-cluster"
  tags     = {}
  tags_all = {}
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}
