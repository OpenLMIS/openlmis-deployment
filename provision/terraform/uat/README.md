# Starting a new environment

## Prerequisites

1. Terraform
1. ansible
1. ssh-agent

# Steps

1. Copy one of the existing environments (e.g. uat3, 4, etc) to a new folder (exclude the `.terraform`)
directory.
1. Update the relevant variables for the new environment in `variables.tf`
1. Change the name of the module to match the folder name in `main.tf`
1. Run `terraform init`, you should see a success message for the name of the module which matches
the name of the folder.
1. Run `terraform plan` and verify things look right.
1. Ensure `ssh-add -l` returns the key file that Ansible will use.
1. Run `terraform apply` and go to AWS to verify the correct resources were provisioned.
