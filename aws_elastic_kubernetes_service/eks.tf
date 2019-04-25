locals {
  worker_groups = [
    {
      instance_type = "t2.medium"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 3
    },
  ]
  worker_groups_launch_template = [
    {
      instance_type = "t2.small"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = "3"
      additional_security_group_ids = "${aws_security_group.worker_mgmt.id}"
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
  worker_groups_launch_template = "${local.worker_groups_launch_template}"
  worker_group_count = "1"
  worker_group_launch_template_count = "1"
  worker_additional_security_group_ids = ["${aws_security_group.worker_mgmt.id}"]
  cluster_enabled_log_types = ["api","controllerManager","scheduler"]
  workers_additional_policies = ["${aws_iam_policy.worker-s3.id}"]
  workers_additional_policies_count = "1"
}
