output "instance_ips" {
  value = ["${aws_instance.instance.*.public_ip}"]
}
