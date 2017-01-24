variable "base_server_ami" {
    type = "string"
    default = "ami-48227e2e"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-west-1"
}

resource "aws_instance" "ns-1" {
  ami = "${var.base_server_ami}"
  instance_type = "t2.small"
  key_name = "testkeypair1"

  tags {
    Name = "ns-1"
  }

  provisioner "remote-exec" {
    script = "./server-bootstrap.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      timeout = "1m"
    }
  }
}
