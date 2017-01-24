provider "aws" {
  access_key = ""
  secret_key = ""
  region = "eu-west-1"
}

resource "aws_instance" "ns-1" {
  ami = "ami-48227e2e"
  instance_type = "t2.small"
  key_name = "testkeypair1"

  tags {
    Name = "ns-1"
  }
}
