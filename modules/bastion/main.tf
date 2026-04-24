resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = var.subnet_id

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  user_data = file("${path.module}/user_data.sh")
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  tags = merge({
    Name = var.instance_name
  }, var.tags)
}