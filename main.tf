locals {
  sample_instance_type = "t3.micro"
}

data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "sample" {
  ami           = data.aws_ssm_parameter.amzn2_ami.value
  instance_type = local.sample_instance_type

  vpc_security_group_ids = [aws_security_group.sample-ec2.id]
  key_name               = aws_key_pair.sample.key_name
  iam_instance_profile   = aws_iam_instance_profile.sample.name

  tags = {
    Name = "sample"
  }
}

resource "aws_iam_instance_profile" "sample" {
  name = "sample-instance-profile"
  role = aws_iam_role.sample.name
}

resource "aws_iam_role" "sample" {
  name = "sample-ec2-iam-role"
  path = "/"

  # 信頼ポリシー
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
              "Service": "ec2.amazonaws.com"
           },
           "Effect": "Allow",
           "Sid": ""
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sample" {
  role       = aws_iam_role.sample.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_security_group" "sample-ec2" {
  name = "sample-ec2"

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"

  # your IP
  #   cidr_blocks = ["xxx.xxx.xxx.xxx/32"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "sample" {
  key_name = "sample-keypair"

  # 以下のコマンドで生成したキーペアの公開鍵を指定
  # ssh-keygen -m PEM -t rsa -b 4096 -f key_name -C ""
  # public_key = "ssh-rsa AAAABBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
}