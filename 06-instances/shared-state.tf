output "instance_ips" {
  value = ["${aws_instance.sgvlug_instance.*.public_ip}"]
}
