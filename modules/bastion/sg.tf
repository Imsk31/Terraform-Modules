#----------------------------------------------------
# Security Group (NO SSH)
#----------------------------------------------------
resource "aws_security_group" "bastion_sg" {
  name   = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} allowing only SSM access"
  vpc_id = var.vpc_id

  # No ingress (SSM only)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.instance_name}-sg"
  }, var.tags)
}