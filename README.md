# Estrutura

```
.
├── asg
├── aws-auth
├── launch
├── master
└── node
```

asg      : Autoscaling Schedule para ASG
aws-auth : Config Maps para autenticação com o cluster
launch   : Launch template personalizado para EKS
master   : Criacao do cluster 
node     : Criacao de node groups

# Inputs

Os inputs são todas as variáveis em que os módulos esperam como dependencia, algumas variáveis serão repassadas por outputs de outros módulos ou data source.


#### asg
|||
|---|---|
|desired_size| Desired number of worker nodes.|
|max_size| Maximum number of worker nodes.|
|min_size| Minimum number of worker nodes.|
|scaledown| ASG scale down cron config|
|scaleup| ASG scale up cron config|
|stop| Next stop config|
|start| Next startup config|
|asg_name| Name of the Node Group ASG.|

#### aws-auth
|||
|---|---|
|map_additional_iam_roles| Additional IAM roles to add to `config-map-aws-auth` ConfigMap|
|map_additional_iam_users| Additional IAM users to add to `config-map-aws-auth` ConfigMap|
|cluster_token| Cluster authentication token|
|cluster_certificate| Amazon EKS CA certificate|
|cluster_endpoint| Amazon EKS private API server endpoint|

#### launch
|||
|---|---|
|instance_type| Instance type definition for worker launch template|
|kubernetes_version| Kubernetes version to use for the EKS cluster.|
|cluster_certificate| Amazon EKS CA certificate.|
|cluster_endpoint| Amazon EKS private API server endpoint.|
|sg| A list of security groups to place the EKS cluster and workers within.|
|cluster_security_group| The EKS cluster managed security groups to place the workers.|
|cluster_name| Name of the EKS cluster. Also used as a prefix in names of related resources.|
|node_name| Name of the Node group. Also used as a prefix in names of related resources.|

#### master
|||
|---|---|
|cluster_name| Name of the EKS cluster. Also used as a prefix in names of related resources.|
|kubernetes_version| Kubernetes version to use for the EKS cluster.|
|private_subnet| A list of private subnets to place the EKS cluster and workers within.|
|public_subnet| A list of public subnets to place the EKS cluster and workers within.|
|cluster_endpoint_private_access| Indicates whether or not the Amazon EKS private API server endpoint is enabled.|
|cluster_endpoint_public_access| Indicates whether or not the Amazon EKS public API server endpoint is enabled.|
|sg| A list of security groups to place the EKS cluster and workers within.|

#### node
|||
|---|---|
|cluster_name| Name of the EKS cluster. Also used as a prefix in names of related resources.|
|private_subnet| A private subnets list to place the EKS cluster and workers within.|
|desired_size| Desired number of worker nodes.|
|max_size| Maximum number of worker nodes.|
|min_size| Minimum number of worker nodes.|
|node_name| Name of the Node group. Also used as a prefix in names of related resources|
|launch_template_name| Launch template name|
|launch_template_version| Launch template version|
|environment| Node Group environment label|

# Outputs

Outputs são saídas que o nosso módulo enviará para que possamos utilizar como input em outro.

#### launch
|||
|---|---|
|launch_template_name| Nome do launch template|
|launch_template_id| Launch template id|
|launch_template_version| Launch template version|

#### master
|||
|---|---|
|cluster_security_group| Cluster security group id|
|cluster_certificate| Amazon EKS CA certificate|
|cluster_token| Cluster authentication token|
|cluster_endpoint| Amazon EKS private API server endpoint|

#### node
|||
|---|---|
|asg_name| Node auto scaling group name|

# Exemplo

Abaixo veremos um exemplo de como esse módulo deve ser utilizado:


#### Data source

Será necessário que realize o datasource de alguns recursos como:

- Subnets publicas
- Subnets privadas
- Security group telecom

#### Módulos

```
module "master" {
  source = "./modules/connect-eks/master"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  private_subnet = tolist([data.aws_subnet.priv1.id, data.aws_subnet.priv2.id])
  public_subnet  = tolist([data.aws_subnet.pub1.id, data.aws_subnet.pub2.id])
  sg        = [data.aws_security_group.telecom.id]

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}

module "aws-auth" {
  source = "./modules/connect-eks/aws-auth"

  cluster_token       = module.master.cluster_token
  cluster_certificate = module.master.cluster_certificate
  cluster_endpoint    = module.master.cluster_endpoint
  map_additional_iam_roles = var.map_additional_iam_roles
  map_additional_iam_users = var.map_additional_iam_users
}

module "node" {
  source = "./modules/connect-eks/node"

  node_name           = var.node_name
  cluster_name        = var.cluster_name

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size

  environment = var.environment
  
  launch_template_name = module.launch_hml.launch_template_name
  launch_template_version = module.launch_hml.launch_template_version

  private_subnet = tolist([data.aws_subnet.priv1.id, data.aws_subnet.priv2.id])

  depends_on = [
    module.launch_hml
  ]
}

module "launch"{
  source = "./modules/connect-eks/launch"

  cluster_name        = var.cluster_name
  node_name           = var.node_name
  kubernetes_version  = var.kubernetes_version

  cluster_security_group = module.master.cluster_security_group
  cluster_certificate = module.master.cluster_certificate
  cluster_endpoint    = module.master.cluster_endpoint

  instance_type  = var.instance_type
  sg        = data.aws_security_group.telecom.id
}

module "asg"{
   source = "./modules/connect-eks/asg"

   asg_name = module.node_hml.asg_name

   desired_size = var.desired_size
   min_size     = var.min_size
   max_size     = var.max_size

   scaledown = var.scaledown
   scaleup = var.scaleup
   stop = var.stop
   start = var.start

   depends_on = [
     module.launch_hml,
     module.node_hml
   ]
}
```

Existindo dúvidas sobre a estrutura, consultar alguns dos projetos já existentes
