resource "aws_security_group" "ec2_sg" {
  name   = "${var.app_name}-ec2-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon2_amd64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.amazon2_amd64.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = "false"
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,
  ]
  iam_instance_profile = aws_iam_instance_profile.ssm_managed_ec2_instance_profile.name
}
