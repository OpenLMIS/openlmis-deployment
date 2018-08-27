# Terraform

Terraform is for defining computing resources as code.  See [Terraform](https://www.terraform.io/).

## Usage

Terraform is still relatively new for OpenLMIS, and so the examples laid out here are not
yet recommended for general use.

### Structure

This follows the format laid out [here](https://blog.ona.io/technology/2018/06/05/automate-your-infrastructure-by-reusing-terraform-definitions.html)

### Importing existing

To import an existing "setup" into terraform:

1. create the setup under the correct environment, e.g. in the uat environment the uat3 setup is
under `uat/uat3`.
1. Run the following terraform commands inside the directory for the setup, e.g. `uat/uat3`.

  ```
  terraform import module.<Name OF SETUP>.aws_instance.app <ID OF INSTANCE>
  terraform import module.<NAME OF SETUP>.aws_elb.elb <NAME OF ELB>
  terraform import module.<NAME OF SETUP>.aws_db_instance.rds <NAME OF RDS INSTANCE>
  ```

### Setup

Use the following steps to set up the machine you'll be running Terraform from:

1. Follow [these](https://www.terraform.io/intro/getting-started/install.html) instructions to install Terraform.

1. Install Ansible and its dependencies using the steps described [here](../ansible/README.md).

1. Make sure the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables are set to credentials that are able to create the resources defined in the Terraform files. You can do this using the instructions described [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html).

1. Copy the `AWS_ACCESS_KEY_ID` and `AWD_SECRET_ACCESS_KEY` environment variables to Terraform variables. The automation scrips will use these Terraform variables to backup TLS certificates and keys for securely connecting to the installed Docker daemon in the S3 bucket specified [here](../ansible/inventory/group_vars/docker-hosts/vars.yml). Use the following commands to set the Terraform variables:

```sh
export TF_VAR_aws-access-key-id=AWS_ACCESS_KEY_ID
export TF_VAR_aws-secret-access-key=AWS_SECRET_ACCESS_KEY
```