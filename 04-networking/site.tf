resource "aws_vpc" "main" {
  cidr_block = "${var.vpc["cidr"]}"

  tags {
    Name      = "${var.resource_prefix}-${var.vpc["name"]}-vpc"
    Preferred = "true"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_subnet" "main" {
  count = "${length(var.subnets)}"
  cidr_block              = "${lookup(var.subnets[count.index], "cidr")}"
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${lookup(var.subnets[count.index], "az")}"

  tags {
    Name = "${var.resource_prefix}-${var.vpc["name"]}-${lookup(var.subnets[count.index], "name")}"
  }
}
