data "aws_subnet" "pub1" {
  filter {
    name   = "tag:Name"
    values = ["Sub-Aplicacao-Pub-us-east-1a"]
  }
}

data "aws_subnet" "pub2" {
  filter {
    name   = "tag:Name"
    values = ["Sub-Aplicacao-Pub-us-east-1c"]
  }
}

data "aws_subnet" "priv1" {
  filter {
    name   = "tag:Name"
    values = ["Sub-Aplicacao-Priv-us-east-1a"]
  }
}

data "aws_subnet" "priv2" {
  filter {
    name   = "tag:Name"
    values = ["Sub-Aplicacao-Priv-us-east-1c"]
  }
}

data "aws_security_group" "acesso_eks" {
  name = "acesso-eks-sg"
}