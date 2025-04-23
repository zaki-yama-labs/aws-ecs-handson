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

data "aws_caller_identity" "current" {}

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

resource "aws_lb" "h4b-ecs-alb" {
  client_keep_alive                                            = 3600
  customer_owned_ipv4_pool                                     = null
  desync_mitigation_mode                                       = "defensive"
  dns_record_client_routing_policy                             = null
  drop_invalid_header_fields                                   = false
  enable_cross_zone_load_balancing                             = true
  enable_deletion_protection                                   = false
  enable_http2                                                 = true
  enable_tls_version_and_cipher_suite_headers                  = false
  enable_waf_fail_open                                         = false
  enable_xff_client_port                                       = false
  enable_zonal_shift                                           = false
  enforce_security_group_inbound_rules_on_private_link_traffic = null
  idle_timeout                                                 = 60
  internal                                                     = false
  ip_address_type                                              = "ipv4"
  load_balancer_type                                           = "application"
  name                                                         = "h4b-ecs-alb"
  name_prefix                                                  = null
  preserve_host_header                                         = false
  security_groups                                              = [aws_security_group.elb_sg.id]
  subnets = [
    aws_subnet.h4b-ecs-subnet-public1-ap-northeast-1a.id,
    aws_subnet.h4b-ecs-subnet-public1-ap-northeast-1c.id,
  ]
  tags                       = {}
  tags_all                   = {}
  xff_header_processing_mode = "append"
  access_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  connection_logs {
    bucket  = ""
    enabled = false
    prefix  = null
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

resource "aws_subnet" "h4b-ecs-subnet-public1-ap-northeast-1a" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "ap-northeast-1a"
  cidr_block                                     = "10.0.0.0/20"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_cidr_block                                = null
  ipv6_native                                    = false
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  tags = {
    Name = "h4b-ecs-subnet-public1-ap-northeast-1a"
  }
  tags_all = {
    Name = "h4b-ecs-subnet-public1-ap-northeast-1a"
  }
  vpc_id = "vpc-0c2cd2bd3d93205ff"
}

resource "aws_subnet" "h4b-ecs-subnet-public1-ap-northeast-1c" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "ap-northeast-1c"
  cidr_block                                     = "10.0.16.0/20"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_cidr_block                                = null
  ipv6_native                                    = false
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  tags = {
    Name = "h4b-ecs-subnet-public2-ap-northeast-1c"
  }
  tags_all = {
    Name = "h4b-ecs-subnet-public2-ap-northeast-1c"
  }
  vpc_id = "vpc-0c2cd2bd3d93205ff"
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

resource "aws_ecs_task_definition" "main" {
  container_definitions = jsonencode([{
    environment      = []
    environmentFiles = []
    essential        = true
    image            = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/h4b-ecs-helloworld:0.0.1"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/h4b-ecs-task-definition"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
        max-buffer-size       = "25m"
        mode                  = "non-blocking"
      }
      secretOptions = []
    }
    mountPoints = []
    name        = "apache-helloworld"
    portMappings = [{
      appProtocol   = "http"
      containerPort = 80
      hostPort      = 80
      name          = "apache-helloworld-80-tcp"
      protocol      = "tcp"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  cpu                      = "1024"
  enable_fault_injection   = false
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  family                   = "h4b-ecs-task-definition"
  ipc_mode                 = null
  memory                   = "3072"
  network_mode             = "awsvpc"
  pid_mode                 = null
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = null
  tags                     = {}
  tags_all                 = {}
  task_role_arn            = null
  track_latest             = false
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_service" "main" {
  availability_zone_rebalancing      = "ENABLED"
  cluster                            = "arn:aws:ecs:ap-northeast-1:144232864051:cluster/h4b-ecs-cluster"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 2
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  force_delete                       = null
  force_new_deployment               = null
  health_check_grace_period_seconds  = 0
  iam_role                           = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  launch_type                        = null
  name                               = "h4b-ecs-service"
  platform_version                   = "LATEST"
  propagate_tags                     = "NONE"
  scheduling_strategy                = "REPLICA"
  tags                               = {}
  tags_all                           = {}
  task_definition                    = "h4b-ecs-task-definition:1"
  triggers                           = {}
  wait_for_steady_state              = null
  alarms {
    alarm_names = []
    enable      = false
    rollback    = false
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 1
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }
  load_balancer {
    container_name   = "apache-helloworld"
    container_port   = 80
    elb_name         = null
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:${data.aws_caller_identity.current.account_id}:targetgroup/h4b-ecs-targetgroup/4a4ea8beed663162"
  }
  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.elb_sg.id]
    subnets = [
      aws_subnet.h4b-ecs-subnet-public1-ap-northeast-1a.id,
      aws_subnet.h4b-ecs-subnet-public1-ap-northeast-1c.id
    ]
  }
}
