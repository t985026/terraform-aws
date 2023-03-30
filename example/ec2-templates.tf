provider "aws" {
  # access_key = "MY_ACCESS_KEY"
  # secret_key = "MY_SECRET_KEY"
  profile = "test"
  region  = "ap-northeast-1"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "awsprops" {
  default = {
    region       = "ap-northeast-1"
    vpc          = "vpc-XXXXXXX"
    ami          = "ami-0cc8b0ca07fee465f" # Ubuntu-20.04
    itype        = "t2.large"
    subnet       = "subnet-XXXXXXX"
    publicip     = true
    keyname      = "somekey"
    secgroupname = ["default"]
    secgroupids  = ["sg-XXXXXXX"]
  }
}

resource "aws_instance" "example" {
  ami                         = lookup(var.awsprops, "ami")
  instance_type               = lookup(var.awsprops, "itype")
  key_name                    = lookup(var.awsprops, "keyname")
  subnet_id                   = lookup(var.awsprops, "subnet")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  vpc_security_group_ids      = lookup(var.awsprops, "secgroupids")

  tags = {
    Name = var.instance_name
  }
  user_data = <<EOF
#!/bin/bash
echo "Installing NodeExporter"
curl -O https://XXXXXX.s3.ap-northeast-1.amazonaws.com/node_exporter/install_node_exporter_amd64.sh
sudo sh install_node_exporter_amd64.sh

EOF

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }

}

output "ec2instance" {
  value = aws_instance.example.public_ip
}


