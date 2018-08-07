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
