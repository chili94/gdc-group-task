# Configure the AWS Provider
provider "aws" {
  region  = "${var.aws_region}"
}

### Create VPC ###

resource "aws_vpc" "customer_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "customer_vpc"
  }
}

### Subnets ###
resource "aws_subnet" "customer_public_subnet_1" {
  vpc_id = "${aws_vpc.customer_vpc.id}"
  cidr_block = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "customer_public_subnet_1"
  }
}

resource "aws_subnet" "customer_public_subnet_2" {
   vpc_id = "${aws_vpc.customer_vpc.id}"
   cidr_block = "${var.cidrs["public2"]}"
   map_public_ip_on_launch = true
   availability_zone = "${data.aws_availability_zones.available.names[1]}"

   tags = {
     Name = "customer_public_subnet_2"
   }
}

### Create IG - Internet Gateway

resource "aws_internet_gateway" "customer_internet_gateway" {
   vpc_id = "${aws_vpc.customer_vpc.id}"
   
   tags = {
     Name = "customer_igw"
   }
}

### Create Route Tables ###

resource "aws_route_table" "customer_public_rt" {
   vpc_id = "${aws_vpc.customer_vpc.id}"
   
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.customer_internet_gateway.id}"
   }

   tags = {
     Name = "customer_public_rt"
   }
}

resource "aws_default_route_table" "customer_private_rt" {
  default_route_table_id = "${aws_vpc.customer_vpc.default_route_table_id}"

  tags = {
    Name = "wp_private_rt"
  }
}

### Associate subnets to RT ###

resource "aws_route_table_association" "customer_public_1_associate" {
   subnet_id = "${aws_subnet.customer_public_subnet_1.id}"
   route_table_id = "${aws_route_table.customer_public_rt.id}"
}

resource "aws_route_table_association" "customer_public_2_associate" {
   subnet_id = "${aws_subnet.customer_public_subnet_2.id}"
   route_table_id = "${aws_route_table.customer_public_rt.id}"
}
