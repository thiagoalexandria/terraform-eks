data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "eks_launch_template" {
  image_id               = data.aws_ssm_parameter.eks_ami.value
  instance_type          = var.instance_type
  name                   = format("${var.node_name}-%s", var.cluster_name)
  update_default_version = true
  
  vpc_security_group_ids = tolist([var.sg, var.cluster_security_group])

  user_data = base64encode(templatefile("${path.module}/userdata.tpl", { CLUSTER_NAME = var.cluster_name, B64_CLUSTER_CA = var.cluster_certificate, API_SERVER_URL = var.cluster_endpoint }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp3"
      delete_on_termination = true
      encrypted = true
    }
  }

  tags = {
      "eks:cluster-name" = var.cluster_name
      "eks:nodegroup-name"	= format("${var.node_name}-%s", var.cluster_name)
    }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = format("${var.node_name}-%s", var.cluster_name)
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
     Name = format("${var.node_name}-%s", var.cluster_name)
    }
  }

}