
#----------------------------------------------------
# IAM Role for SSM
#----------------------------------------------------
resource "aws_iam_role" "ssm_role" {
  name = "${var.instance_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#----------------------------------------------------
# Instance Profile
#----------------------------------------------------
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ssm_role.name
}