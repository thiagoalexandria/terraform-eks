module "node_hml" {
  source = "./modules/connect-eks/node"

//Node
  node_name           = var.node_name
  cluster_name        = var.cluster_name
  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
  environment = var.environment
  private_subnet = tolist([data.aws_subnet.priv1.id, data.aws_subnet.priv2.id])

//Launch
  kubernetes_version  = var.kubernetes_version
  cluster_security_group = module.master.cluster_security_group
  cluster_certificate = module.master.cluster_certificate
  cluster_endpoint    = module.master.cluster_endpoint
  instance_type  = var.instance_type
  sg        = data.aws_security_group.acesso_eks.id

}

module "namespace_hml"{
  source = "./modules/connect-eks/namespace"

  for_each = toset(["autoacordo-service","boleto-service","cards-api-moai","cards-api-mobile","config-servive","external-service","middleware","middleware-market-go","middleware-portall","middleware-portal-pier","middleware-toten","mongo-middleware","mongo-yupi","monitoria-moai","pukao-service","registry-service","toten-pdv","toten-service"])

  namespace_name = "${each.key}"
}
