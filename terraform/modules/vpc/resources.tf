locals {
  common_tags = merge(var.tags, { module = "vpc" })

  # Tags EKS: el control plane y los load balancers descubren las subnets por estas etiquetas
  eks_tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  } : {}
}

# --- VPC base ---
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-vpc" })
}

# --- Internet Gateway (salida pública) ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-igw" })
}

# --- Subnets públicas + ruteo ---
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, local.eks_tags, { Name = "${var.name_prefix}-public-${count.index + 1}", "kubernetes.io/role/elb" = "1" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Subnets privadas (+ NAT opcional) ---
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, local.eks_tags, { Name = "${var.name_prefix}-private-${count.index + 1}", "kubernetes.io/role/internal-elb" = "1" })
}

resource "aws_route_table" "private" {
  count  = var.enable_nat ? length(var.private_subnet_cidrs) : 1
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-private-rt" })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat ? length(var.private_subnet_cidrs) : 0
  domain = "vpc"

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? length(var.private_subnet_cidrs) : 0
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-nat-${count.index + 1}" })
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat ? length(var.private_subnet_cidrs) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id

  depends_on = [aws_route_table.private]
}