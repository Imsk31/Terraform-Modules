#----------------------------------------------------
# Security Group for RDS
#----------------------------------------------------

resource "aws_security_group" "rds_sg" {
  name        = "${var.db_name}-rds-sg"
  description = "Allow DB access from allowed sources"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow DB access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
        Name = "${var.db_name}-sg"
    }, 
    var.tags)
}