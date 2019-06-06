# AWS VPC and PostgreSQL example stack

This is an example AWS stack that provides the minimum requirements for the
[AWS EKS
Migration](https://github.com/codecov/enterprise-resources/tree/master/aws_eks_migration) 
stack to operate.  It is intended to be used to test
the migration stack operates correctly, but it can also be used to inform you
on what minimum required resource the migration stack expects.
It consists of:
- A VPC
- Public and private subnets spanning for each of 3 availability zones.
- An RDS Postgres instance
- An S3 bucket for coverage report storage.

## Getting Started

- Install the [aws
  cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
  tool.
- Install the
  [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
  utility.
- Create a new [IAM
  user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html).
- Attach the [AdministratorAccess
  policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_administrator) to your newly created user.
- [Create access
  keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html?icmpid=docs_iam_console)
  for your IAM user.
- [Configure your aws
  cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration) 
  to use the above access keys.  It is recommended to install these keys in
  a profile (ex: `aws configure --profile codecov`).
- Export AWS_PROFILE the variable using your `~/.bash_profile` or a tool
  like [direnv](https://direnv.net/).
    ```
    export AWS_PROFILE=codecov
    ```

## Configuration

The terraform stack is configured using terraform variables which can be
defined in a `terraform.tfvars` file.  More info on
[Terraform input variables](https://www.terraform.io/docs/configuration/variables.html).

| name | description | default |
| --- | --- | --- |
| `region` | AWS region | us-east-1 |
| `postgres_instance_class` | Instance class for PostgreSQL RDS instance | db.t3.micro |
| `postgres_skip_final_snapshot` | Whether to skip taking a final snapshot when destroying the Postgres DB. It is recommended to keep this set to 0 in production in order to avoid unintended data loss. | 0 |

## Executing terraform

After configuring `terraform.tfvars` you are ready to execute
terraform and create the stack following these steps:

1. Run `terraform init`.  This will download the necessary provider modules and
   prepare your terraform environment for execution.  [Terraform
   init](https://www.terraform.io/docs/commands/init.html)
1. Create a plan: `terraform plan -out=plan.out`.  This checks the current
   state and saves an execution plan to `plan.out`.  [Terraform
   plan](https://www.terraform.io/docs/commands/plan.html)
1. If you're satisfied with the execution plan, apply it.  `terraform apply
   plan.out`.  This will begin creating your stack.  [Terraform
   apply](https://www.terraform.io/docs/commands/apply.html)
1. Wait... this will take a little while.  If everything goes well, you will
   see something like this:
     ```
     [...]
     
     Apply complete! Resources: 36 added, 0 changed, 0 destroyed.
    Outputs:

    postgres-password = xxxxxxxxxxxx
    postgres-username = codecov
    postgres_url = postgres://codecov:xxxxxxxxxxxx@codecov-postgres-xxx.xxxxxxxxxx.us-east-1.rds.amazonaws.com:5432/codecov
    s3_bucket = codecov-minio-epic-worm
    vpc_id = vpc-xxxxxxxxxxxxxxxxx
    vpc_private_subnet_ids = [
        subnet-xxxxxxxxxxxxxxxxx,
        subnet-xxxxxxxxxxxxxxxxx,
        subnet-xxxxxxxxxxxxxxxxx
    ]
     ```
1. The above outputs can be used to test the [AWS EKS
   Migration](https://github.com/codecov/enterprise-resources/tree/master/aws_eks_migration)
   stack by including them in its `terraform.tfvars` file.

## Destroying

If you want to remove your this stack, execute `terraform
destroy`.  *This will remove all of your enterprise configuration and uploaded
coverage reports.*  All resources created with terraform will be removed, so
please use with caution.
