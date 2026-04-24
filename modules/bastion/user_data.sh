#!/bin/bash
set -xe

# Update system
yum update -y || apt update -y

# Install SSM agent (in case AMI doesn't have it)
if ! systemctl status amazon-ssm-agent >/dev/null 2>&1; then
  if command -v yum >/dev/null 2>&1; then
    yum install -y amazon-ssm-agent
  else
    snap install amazon-ssm-agent --classic
  fi
fi

systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service