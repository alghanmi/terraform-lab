output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet01_id" {
  value = "${aws_subnet.main.0.id}"
}

output "subnet02_id" {
  value = "${aws_subnet.main.1.id}"
}

output "subnets" {
  value = ["${aws_subnet.main.*.id}"]
}
