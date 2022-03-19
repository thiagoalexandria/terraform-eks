// Master
variable "cluster_name" {
  type    = string
  default = "LAB-MOBILE"
}
variable "kubernetes_version" {
  type    = string
  default = "1.19"
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = false
}

//Node HML
variable "desired_size" {
  type    = string
  default = "1"
}
variable "max_size" {
  type    = string
  default = "1"
}
variable "min_size" {
  type    = string
  default = "1"
}
variable "instance_type" {
  type    = string
  default = "t3a.xlarge"
}
variable "node_name"{
  type    = string
  default = "NG-HML"
}

variable "environment" {
  type    = string
  default = "hml"
}

//ASG
variable "scaledown" {
    type = string
    default = "00 23 * * 1-5"
}

variable "scaleup" {
    type = string
    default = "30 10 * * 1-5"
}

variable "stop" {
    type = string
    default = null
}

variable "start" {
    type = string
    default = null
}

// namespace
variable "namespace_name" {
  type = string
  default = "hml"
}

// aws-auth

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::138511992678:role/OrganizationAccountAccessRole"
      username = "prod.role"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::138511992678:role/eks-node-role"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers","system:nodes"]
    },    
    {
      rolearn  = "arn:aws:iam::138511992678:role/TerraformSuperAccessRole"
      username = "terraform.role"
      groups   = ["system:masters"]
    }
  ]
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::138511992678:user/kubectl-user"
      username = "kubectl-user"
      groups   = ["system:masters"]
    },   
    {
      userarn  = "arn:aws:iam::138511992678:user/bruno.santos"
      username = "bruno.santos"
      groups   = ["system:masters"]
    },
  ]
}
