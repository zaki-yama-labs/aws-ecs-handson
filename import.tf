import {
  to = aws_ecr_repository.service
  id = "h4b-ecs-helloworld"
}

import {
  to = aws_vpc.main
  id = "vpc-0c2cd2bd3d93205ff"
}

import {
  to = aws_security_group.elb_sg
  id = "sg-082f10f24a48912bb"
}

import {
  to = aws_ecs_cluster.main
  id = "h4b-ecs-cluster"
}

import {
  to = aws_ecs_task_definition.main
  id = "arn:aws:ecs:ap-northeast-1:${data.aws_caller_identity.current.account_id}:task-definition/h4b-ecs-task-definition:1"
}

import {
  to = aws_ecs_service.main
  id = "h4b-ecs-cluster/h4b-ecs-service"
}

import {
  to = aws_subnet.h4b-ecs-subnet-public1-ap-northeast-1a
  id = "subnet-0beab921fa72d1f0e"
}

import {
  to = aws_subnet.h4b-ecs-subnet-public1-ap-northeast-1c
  id = "subnet-071971428d2038ca7"
}



