

# --------------------
# VPC
# --------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "chaos-vpc" }
}

# --------------------
# SUBNETS
# --------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-a" }
}

resource "aws_subnet" "public_b" {
  count                   = var.multi_az ? 1 : 0
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-b" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"
  tags              = { Name = "private-a" }
}

resource "aws_subnet" "private_b" {
  count             = var.multi_az ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"
  tags              = { Name = "private-b" }
}

# --------------------
# INTERNET GATEWAY
# --------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "chaos-igw" }
}

# --------------------
# NAT GATEWAYS (HA)
# --------------------
resource "aws_eip" "nat_a" {
  tags = { Name = "chaos-nat-eip-a" }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "chaos-nat-a" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_b" {
  count = var.multi_az ? 1 : 0
  tags  = { Name = "chaos-nat-eip-b" }
}

resource "aws_nat_gateway" "nat_b" {
  count         = var.multi_az ? 1 : 0
  allocation_id = var.multi_az ? aws_eip.nat_b[0].id : null
  subnet_id     = aws_subnet.public_b[0].id
  tags          = { Name = "chaos-nat-b" }
  depends_on    = [aws_internet_gateway.igw]
}

# --------------------
# ROUTE TABLES
# --------------------
# Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  count          = var.multi_az ? 1 : 0
  subnet_id      = aws_subnet.public_b[0].id
  route_table_id = aws_route_table.public.id
}

# Private
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = { Name = "private-rt-a" }
}

resource "aws_route_table" "private_b" {
  count = var.multi_az ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b[0].id
  }

  tags = { Name = "private-rt-b" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  count          = var.multi_az ? 1 : 0
  subnet_id      = aws_subnet.private_b[0].id
  route_table_id = aws_route_table.private_b[0].id
}

# --------------------
# EKS CLUSTER
# --------------------
resource "aws_eks_cluster" "chaos_cluster" {
  name     = "chaos-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.multi_az ? [
      aws_subnet.private_a.id,
      aws_subnet.private_b[0].id
    ] : [
      aws_subnet.private_a.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller
  ]
}

# --------------------
# EKS NODE GROUP (with topology spread)
# --------------------
resource "aws_eks_node_group" "chaos_nodes" {
  cluster_name    = aws_eks_cluster.chaos_cluster.name
  node_group_name = "chaos-nodes"
  instance_types  = ["t3.micro"]
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.multi_az ? [
    aws_subnet.private_a.id,
    aws_subnet.private_b[0].id
  ] : [
    aws_subnet.private_a.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  labels = {
    "purpose" = "chaos-testing"
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.chaos_cluster.name}" = "owned"
    "topology.kubernetes.io/zone" = "spread"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only
  ]
}
