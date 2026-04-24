output "instance_id" {
  value = aws_instance.main.id
}
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}