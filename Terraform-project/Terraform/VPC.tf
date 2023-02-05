#################################################################
##                 creating VPC                                ##
#################################################################


resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "Green_vpc"
  }
}


#################################################################
##                 creating Subnet                                ##
#################################################################

resource "aws_subnet" "my_subnet" {
  count             = var.my_vpc == "10.0.0.0/16" ? 3 : 0
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = element(cidrsubnets(var.my_vpc, 8, 4, 4), count.index)
  tags = {
    "Name" = "Green-Subnet-${count.index}"
  }
}



#################################################################
##                 creating route table                        ##
#################################################################

resource "aws_route_table" "my_vpc-rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    "Name" = "Green-route-table"
  }
}

#################################################################
##             creating route table association                ##
#################################################################

resource "aws_route_table_association" "rt_assos" {
  count          = length(aws_subnet.my_subnet) == 3 ? 3 : 0
  subnet_id      = element(aws_subnet.my_subnet.*.id, count.index)
  route_table_id = aws_route_table.my_vpc-rt.id
}

#################################################################
##               creating Internet gateway                     ##
#################################################################

resource "aws_internet_gateway" "my_vpc-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    "Name" = "Green-internet-gateway"
  }
}

#################################################################
##             creating internet-route                         ##
#################################################################

resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.my_vpc-rt.id
  gateway_id             = aws_internet_gateway.my_vpc-igw.id
}


  count          = length(aws_subnet.my_subnet) == 3 ? 3 : 0
  subnet_id      = element(aws_subnet.my_subnet.*.id, count.index)
  vpc_id     = aws_vpc.my_vpc.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
