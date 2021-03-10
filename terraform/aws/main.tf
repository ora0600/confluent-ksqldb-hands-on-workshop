resource "aws_security_group" "sec-ksqldb-demo" {
  name        = "SecGroupConfluentKSQLDBDemo"
  description = "Security Group for Confluent KSQLDB Demo Confluent Platform setup"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # GEO-App
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # C3 Access
  ingress {
    from_port   = 9021
    to_port     = 9021
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Connect Access
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # KSQL Access
  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ksqldb-demo" {
  ami           = "${data.aws_ami.ami.id}"
  count         = var.instance_count
  instance_type = var.instance_type_resource
  key_name      = var.ssh_key_name
  vpc_security_group_ids = ["${aws_security_group.sec-ksqldb-demo.id}"]
  user_data = data.template_file.confluent_instance.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  tags = {
    "Name" = "Confluent KSQLDB Demo",
    "Owner" = "cmutzlitz@confluent.io"
  }
}
