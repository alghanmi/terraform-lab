data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "rami_alghanmi" {
  key_name   = "rami_alghanmi"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGnvL6iCCx/yJGXjkTJ8aL5DLDOWoojme8HqHfr6wQBiBSMG4aUQlV7d5GxIdhg49StDr39nGDpsSTyrlRILshRphwscBo7KKrZU8opSMxTcby8oRaCGPq9SbkMbasOXSHywXtY3OnbFioaeXaODuOMO8aGCXLSEsebi0qAZzb592G+TixtOklkBywHpchyuyHyM+3+eGflqCdfg5O7hsKol8gSINBhnLsFT6BmUP8IwRs0nGTMzdWSna/K5ijH07tqWIuoK4pApJGDRLOIuxoDVlzp4aFIx0AK+haUNcX6sU672J9aT4ImwObw9Cg+sUNta18YFvj+qhFKICf9siyWa/3d41Lv5e7bMRhh7z7i4LCbDegO3W3qXefI9BzUOgeYiNqee0nzrX+QMy9T7+jmLorq/VfyYWbmkPv6fu/kpjpYeYbRvFndc4QWHRpgRP19VHVxiTyj1PZJlkJXd2lplB9R1JeFJyr1m28o+Z4HP660+3MrWj5ynx7Mofn4/frmBa5lBIi5cALOeWFuN/9E9/FK55cstagGtkbvC5IXuub+yqabDaZJ4ByT0YQ8JimL/QC53rBvNVilxBv+UK5gSg8U+EB15yTJoZP8DupBVTAdRQyau1XzplFCfaDVJSCJb9hr7bAfBUfU69mya9MiUn7GGd9zXPSMaQiJX41HQ=="
}

resource "aws_security_group" "allow_ssh_ingress" {
  name        = "${var.resource_prefix}-allow-ssh-from-all"
  description = "Allow SSH From all"
  vpc_id      = "${data.terraform_remote_state.networking.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${map(
    "Name", "${var.resource_prefix}-allow-ssh-from-all"
  )}"
}

resource "aws_instance" "sgvlug_instance" {
  count         = "${var.instance_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"
  key_name      = "${aws_key_pair.rami_alghanmi.key_name}"
  subnet_id     = "${element(data.terraform_remote_state.networking.subnets, count.index)}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh_ingress.id}",
  ]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = "${map(
    "Name", "${var.resource_prefix}-instance-${count.index}"
  )}"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["ami", "user_data", "tags.%", "volume_tags.%"]
  }
}
