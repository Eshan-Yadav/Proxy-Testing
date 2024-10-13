module "instance" {
  source                      = "cloudposse/ec2-instance/aws"
  ssh_key_pair                = aws_key_pair.generated_key.key_name
  instance_type               = "t3.medium"
  availability_zone           = "us-east-1a"
  root_volume_size            = 60 
  vpc_id                      = aws_vpc.main.id
  security_groups             = [aws_security_group.allow_all.id]
  subnet                      = aws_subnet.main.id
  name                        = "proxy-instance"
  namespace                   = "eg"
  stage                       = "dev"
  ami                         = data.aws_ami.win2022.id
  associate_public_ip_address = true
  instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_ssm_policies" {
  for_each = {
    "AmazonSSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    "AmazonEC2RoleforSSM"          = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  }

  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = each.value
}


resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" 
  tags = {
    Name = "proxy"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"  
  availability_zone = "us-east-1a"

  tags = {
    Name = "proxy"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "proxy-allow-all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "proxy_testing_key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main Internet Gateway"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local" 
  }

  tags = {
    Name = "Main Route Table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}


output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}



# Selecting AMI for the instance
# data "aws_ami" "amzn2" {
#   owners      = ["amazon"]
#   most_recent = true
#   filter {
#     name = "name"
#     values = ["amzn2-ami-hvm-2*"]
#   }
# }

#windows AMI
data "aws_ami" "win2022" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}


output "ami_id" {
  value = data.aws_ami.win2022.id
}

output "ami_name" {
  value = data.aws_ami.win2022.name
}
