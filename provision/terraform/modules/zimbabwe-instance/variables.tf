variable "name" {
  type        = "string"
  description = "Name of the environment"
}

variable "bill-to" {
  type        = "string"
  description = "Which project to bill the provisioned resources"
  default     = "OpenLMIS"
}

variable "aws-tls-cert-domain" {
  type        = "string"
  description = "Domain name of a TLS certificate in AWS Certificate Manager. It is probably *.app-route53-zone-name if that is set."
  default     = "*.openlmis.org"
}

variable "app-instance-ssh-user" {
  type        = "string"
  description = "The name of the user to connect as in the app host"
}

variable "app-instance-ssh-key-name" {
  type        = "string"
  description = "The name of the AWS key pair to use for the instance",
  default     = "ZimbabweKeyPair"
}

variable "docker-ansible-dir" {
  type        = "string"
  description = "The path to the directory containing the playbook for installing docker"
}

variable "docker-tls-port" {
  type        = "string"
  description = "The TCP port The Docker Daemon is listening for TLS traffic"
}

variable "app-tls-s3-access-key-id" {
  type        = "string"
  description = "The AWS access key ID to use to backup generated Docker TLS files"
}

variable "app-tls-s3-secret-access-key" {
  type        = "string"
  description = "The AWS secrect access key to use to backup generated Docker TLS files"
}

variable "app-dns-name" {
  type        = "string"
  description = "The DNS name associated to the app instance"
}

variable "app-use-route53-domain" {
  type        = "string"
  description = "Whether to use route53 for DNS"
  default     = false
}

variable "app-route53-zone-name" {
  type        = "string"
  description = "The DNS name for a route53 hosted zone already set up in AWS. app-dns-name should be a subdomain of this."
  default     = ""
}

variable "app-instance-group" {
  type        = "string"
  description = "The deployment group to place the app host. Will dictate what Ansible playbooks can ran on it"
}

variable "olmis-db-instance-class" {
  type        = "string"
  description = "The RDS db instance type. If left empty then RDS instance will not be used."
}

variable "olmis-db-username" {
  type        = "string"
  description = "PostgreSQL database username."
}

variable "olmis-db-password" {
  type        = "string"
  description = "The PostgreSQL database password."
}

variable "vpc-security-group-id" {
  type        = "string"
  description = "ID of the security group, specifying inbound/outbound rules"
  default     = "sg-0ab4afdeddf5666e6"
}
