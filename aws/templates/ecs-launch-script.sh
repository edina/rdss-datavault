#!/bin/bash

echo ECS_CLUSTER=${cluster} > /etc/ecs/ecs.config

yum install -y wget

wget https://github.com/awslabs/service-discovery-ecs-dns/releases/download/1.2/ecssd_agent -O /usr/local/bin/ecssd_agent
chmod 755 /usr/local/bin/ecssd_agent

wget https://raw.githubusercontent.com/awslabs/service-discovery-ecs-dns/1.2/ecssd_agent.conf -O /etc/init/ecssd_agent.conf
chmod 644 /etc/init/ecssd_agent.conf
initctl reload-configuration

start ecssd_agent

