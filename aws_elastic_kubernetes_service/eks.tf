locals {
  worker_groups = [
    {
      name = "web"
      instance_type = "t2.medium"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 2
      kubelet_extra_args = "--node-labels=kubernetes.io/role=web"
    },
    {
      name = "worker"
      instance_type = "t2.medium"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 2
      kubelet_extra_args = "--node-labels=kubernetes.io/role=worker"
    },
    {
      name = "minio"
      instance_type = "t2.medium"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 2
      kubelet_extra_args = "--node-labels=kubernetes.io/role=minio"
    },
  ]
}

resource "aws_security_group" "worker_mgmt" {
  name_prefix = "worker_mgmt"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${module.vpc.vpc_cidr_block}",
    ]
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.cluster_name}"
  subnets = ["${module.vpc.private_subnets}"]
  vpc_id = "${module.vpc.vpc_id}"
  worker_groups = "${local.worker_groups}"
  worker_group_count = "3"
  worker_additional_security_group_ids = ["${aws_security_group.worker_mgmt.id}"]
  cluster_enabled_log_types = ["api","controllerManager","scheduler"]
  workers_additional_policies = ["${aws_iam_policy.worker-s3.id}"]
  workers_additional_policies_count = "1"
}
