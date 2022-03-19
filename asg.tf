module "asg_hml"{
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
     module.node_hml
   ]
}
