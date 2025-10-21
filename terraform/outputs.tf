output "vpc_id" {
  value = aws_vpc.main.id
}


output "eks_endpoint" {
  value = aws_eks_cluster.chaos_cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.chaos_cluster.arn
}

output "eks_nodegroup_arn" {
  value = aws_eks_node_group.chaos_nodes.arn
}


output "public_subnets" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnets" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}
