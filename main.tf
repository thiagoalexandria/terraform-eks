#Lab Provider
provider "aws" {
  region = "us-east-1"

  # Antecao para o Account ID no Arn da Role.!!!!!!!!!!!
  assume_role {
    # The role ARN within Account B to AssumeRole into.
    role_arn     = ""
    session_name = "terraform_cross_account_access"
  }
}

provider "kubernetes" {
  host                   = module.master.cluster_endpoint
  cluster_ca_certificate = base64decode(module.master.cluster_certificate)
  token                  = module.master.cluster_token
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-backend-new-lab"
    key            = "eks/mobile-eks.tfstate"
    region         = "us-east-1"
    encrypt        = true

    # Antecao para o Account ID no Arn da Role.!!!!!!!!!!!
    role_arn = ""
  }

}

// Módulos e recursos devem ser chamados logo abaixo
module "aws-auth" {
  source = "./modules/connect-eks/aws-auth"

  map_additional_iam_roles = var.map_additional_iam_roles
  map_additional_iam_users = var.map_additional_iam_users
}
