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
  public_key = "${var.ssh_key}"
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

resource "aws_instance" "instance" {
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
