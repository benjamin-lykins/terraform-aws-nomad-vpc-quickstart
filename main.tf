variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "dev"
}

data "aws_availability_zones" "available" {
  state  = "available"
  region = var.aws_region
}

// VPC
resource "aws_vpc" "main" {

  region = var.aws_region

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.prefix}-vpc" }
}

// Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  region = var.aws_region

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  region = var.aws_region

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-private-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  region = var.aws_region

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

// NAT Gateways
resource "aws_nat_gateway" "ngw" {
  count = length(var.private_subnet_cidrs) > 0 ? 1 : 0

  region = var.aws_region

  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"
}

// Routes and Route Table Associations
resource "aws_route_table" "rtb_public" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  region = var.aws_region

  vpc_id = aws_vpc.main.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.prefix}-rtb-public"
  }
}

resource "aws_route" "route_public" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  region = var.aws_region

  route_table_id         = one(aws_route_table.rtb_public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = one(aws_internet_gateway.igw.*.id)
}

resource "aws_route_table" "rtb_private" {
  count = length(var.private_subnet_cidrs)

  region = var.aws_region

  vpc_id = aws_vpc.main.id

  depends_on = [aws_nat_gateway.ngw]

  tags = {
    Name = "${var.prefix}-rtb-private-${count.index}"
  }
}

resource "aws_route" "route_private" {
  count = length(var.private_subnet_cidrs)

  region = var.aws_region

  route_table_id         = element(aws_route_table.rtb_private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

resource "aws_route_table_association" "rtbassoc-public" {
  count = length(var.public_subnet_cidrs)

  region = var.aws_region

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = one(aws_route_table.rtb_public.*.id)
}

resource "aws_route_table_association" "rtbassoc-private" {
  count = length(var.private_subnet_cidrs)

  region = var.aws_region

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.rtb_private.*.id, count.index)
}


// Broken when using AWS provider 6.0++ due to issue
// https://github.com/hashicorp/terraform-provider-aws/issues/44402

# data "aws_vpc_endpoint_service" "s3_endpoint" {
#   service         = "s3"
#   service_type    = "Gateway"
#   service_regions = [var.aws_region]
# }

resource "aws_vpc_endpoint" "s3_endpoint" {

  region = var.aws_region

  vpc_id = aws_vpc.main.id

  // Using service_name directly due to issue with data source
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${var.prefix}-s3-vpc-endpoint",
    type = "gateway"
  }
}

resource "aws_vpc_endpoint_route_table_association" "rtbassoc_s3_public" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  region = var.aws_region

  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
  route_table_id  = one(aws_route_table.rtb_public.*.id)
}

resource "aws_vpc_endpoint_route_table_association" "rtbassoc_s3_private" {
  count = length(var.private_subnet_cidrs)

  region = var.aws_region

  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
  route_table_id  = element(aws_route_table.rtb_private.*.id, count.index)
}
