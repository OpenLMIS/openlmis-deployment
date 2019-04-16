# Terraform & Ansible

Terraform is for defining computing resources as code.  See 
[Terraform](https://www.terraform.io/).

Ansible is used by terraform to set the provisioned resources up.  i.e. the 
Ansible scripts are used by Terraform to install Docker, setup certificates, 
etc.

Together these two help define our infrastructure as code.

## Install

Installation should be done on a machine that will control the targets.  This is 
most likely your development computer.

1. Install [terraform](https://www.terraform.io/).
1. Install [ansible](https://www.ansible.com/).
  
    * Note that installing on OSX has been reported to be tricky.  You _should_ 
      use virtualenv otherwise errors seem to be likely.  This 
      [guide](https://medium.com/@briantorresgil/definitive-guide-to-python-on-mac-osx-65acd8d969d0) 
      is useful for OSX users. Use Python 2.x, not 3.x.  When using a virtualenv, 
      **do not** use `sudo pip install`, instead drop the `sudo` which allows pip
      to install ansible in the virtualenv.
    * `mkvirtualenv olmis-deployment` if you need a new virtual environment.

1. Install the requirements for our Ansible scripts:
  `pip install ../ansible/requirements/ansible.pip`


## Usage

Terraform & Ansible is still relatively new for OpenLMIS, and so the examples 
laid out here are not yet recommended for general use.

### Teraform Structure

This follows the format laid out [here](https://blog.ona.io/technology/2018/06/05/automate-your-infrastructure-by-reusing-terraform-definitions.html)

### Importing existing

To import an existing "setup" into terraform:

1. create the setup under the correct environment, e.g. in the uat environment 
  the uat3 setup is under `uat/uat3`.
1. Run the following terraform commands inside the directory for the setup, 
  e.g. `uat/uat3`.

    ```
    terraform init
    terraform import module.<Name OF SETUP>.aws_instance.app <ID OF INSTANCE>
    terraform import module.<NAME OF SETUP>.aws_elb.elb <NAME OF ELB>
    terraform import module.<NAME OF SETUP>.aws_db_instance.rds <NAME OF RDS INSTANCE>
    ```

### Setup

Use the following steps to set up the machine you'll be running Terraform from:

1. Make sure the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment 
  variables are set to credentials that are able to create the resources defined 
  in the Terraform files. You can do this using the instructions described 
  [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html).
1. Copy the `AWS_ACCESS_KEY_ID` and `AWD_SECRET_ACCESS_KEY` environment 
  variables to Terraform variables. The automation scrips will use these 
  Terraform variables to backup TLS certificates and keys for securely 
  connecting to the installed Docker daemon in the S3 bucket specified 
  [here](../ansible/inventory/group_vars/docker-hosts/vars.yml). Use the 
  following commands to set the Terraform variables:

    ```sh
    export TF_VAR_aws_access_key_id=$AWS_ACCESS_KEY_ID
    export TF_VAR_aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
    ```

1. Add the right key to SSH-Agent.  e.g. `ssh-add TestEnvDockerHost.env`

### Creating openlmis infrastructure from existing environment

1. `cd` to directory holding environment.  e.g. `cd uat/uat3`
1. Ensure you're using the right virtualenv. e.g. `workon openlmis-deployment`
1. (optional) `terrform plan` to see which resources will be created.
1. `terraform apply` to create the environment.
1. Create/update the DNS CNAME in Gandi to point to the new ELB.
1. Once done the needed Docker TLS client keys will be in the S3 bucket 
`aws-instance-keys`:
    1. Download the following files from `/tls/<name of environment>/<ip>/<date>/`:
        - `ca/cert.pem` -> `ca.pem`
        - `jenkins/key.pem` -> `key.pem`
       - `jenkins/cert.pem` -> `cert.pem`
    1. Zip the above files into `DockerClientTls-<name of environemt>.zip`
    1. Upload Zip file above to Jenkins Credentials and use in `deploy-to` job.
1. Remember to install required Postgres extensions (postgis and uuid-ossp) on RDS database.
  It seems that pre-installed 'uuid-ossp' extension is not working correctly 
  so you may need to uninstall it first. e.g.
    1. `CREATE EXTENSION postgis;`
    1. `DROP EXTENSION "uuid-ossp"`
    1. `CREATE EXTENSION "uuid-ossp"`