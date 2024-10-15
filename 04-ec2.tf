data "aws_ami" "amazon_linux_23" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

locals {
  instance_type = "t2.micro"
}

module "public_ec2" {
  source = "./modules/ec2"

  name          = "${var.project_name}-public-ec2"
  ami_id        = data.aws_ami.amazon_linux_23.id
  instance_type = local.instance_type
  key_name      = var.key_name

  availability_zone  = element(module.vpc.availability_zones, 0)
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.public_ec2_sg.security_group_id]

  associate_public_ip = true
}

module "private_ec2" {
  source = "./modules/ec2"

  name          = "${var.project_name}-private-ec2"
  ami_id        = data.aws_ami.amazon_linux_23.id
  instance_type = local.instance_type
  key_name      = var.key_name

  availability_zone  = element(module.vpc.availability_zones, 1)
  subnet_id          = module.vpc.private_subnet_ids[0]
  security_group_ids = [module.private_ec2_sg.security_group_id]

  associate_public_ip = false
}