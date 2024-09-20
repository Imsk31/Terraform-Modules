resource "aws_subnet" "subnet"{
    vpc_id = aws_vpc.terraform_vpc.id
    name = var.subnet_name
}