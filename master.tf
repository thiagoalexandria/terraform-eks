module "master" {
  source = "./modules/connect-eks/master"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  private_subnet = tolist([data.aws_subnet.priv1.id, data.aws_subnet.priv2.id])
  public_subnet  = tolist([data.aws_subnet.pub1.id, data.aws_subnet.pub2.id])
  sg        = [data.aws_security_group.acesso_eks.id]

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}