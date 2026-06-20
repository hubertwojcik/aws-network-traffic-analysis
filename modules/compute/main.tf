locals {
  name_prefix = "${var.project_name}-${var.environment}"
}


resource "aws_security_group" "attacker_sg" {
  name        = "${local.name_prefix}-attacker-sg"
  description = "Security group for attacker instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-attacker-sg"
  })
}


resource "aws_security_group" "victim_normal" {
  name        = "${local.name_prefix}-sg-victim-normal"
  description = "Victim normal SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-sg-victim-normal"
  })
}


resource "aws_security_group_rule" "victim_ssh_from_attacker" {
  type                     = "ingress"
  description              = "Allow SSH from attacker SG"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.victim_normal.id
  source_security_group_id = aws_security_group.attacker_sg.id
}


resource "aws_security_group_rule" "attacker_ssh_from_victim" {
  type                     = "ingress"
  description              = "Allow SSH from victim SG"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.attacker_sg.id
  source_security_group_id = aws_security_group.victim_normal.id
}


resource "aws_security_group" "victim_quarantine" {
  name        = "${local.name_prefix}-sg-victim-quarantine"
  description = "Victim quarantine SG (isolation)"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-sg-victim-quarantine"
  })
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "attacker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [aws_security_group.attacker_sg.id]
  key_name               = var.ssh_key_name

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-ec2-attacker"
    Role = "attacker"
  })
}

resource "aws_instance" "victim" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [aws_security_group.victim_normal.id]
  key_name               = var.ssh_key_name

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-ec2-victim"
    Role = "victim"
  })
}
