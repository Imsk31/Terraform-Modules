#----------------------------------------------------
# RDS Subnet Group
#----------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    {
        Name = "${var.identifier}-subnet-group"
    }, 
    var.tags)
}

#----------------------------------------------------
# RDS Instance
#----------------------------------------------------

resource "aws_db_instance" "main" {
  engine                 = var.rds_engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  storage_encrypted      = var.storage_encrypted
  
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  identifier             = var.identifier
  db_name                = var.db_name   
  username               = var.username
  password_wo            = var.password_wo
  password_wo_version    = var.password_wo_version
  
  snapshot_identifier    = var.snapshot_identifier
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection

  tags = merge(
    {
        Name = var.identifier
    }, 
    var.tags)
}