output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_sg_id" {
  value = aws_security_group.cluster_sg.id
}

output "node_sg_id" {
  value = aws_security_group.node_sg.id
}

output "lb_sg_id" {
  value = aws_security_group.lb_sg.id
}