variable "name" {
  type        = "string"
  description = "Name of the environment"
}

variable "bill-to" {
  type        = "string"
  description = "Which project to bill the provisioned resources"
  default     = "OpenLMIS"
}

variable "http-port" {
  type        = "string"
  description = "Traffic to this port will be routed to Grafana"
  default     = "80"
}

variable "https-port" {
  type        = "string"
  description = "Traffic to this port will be routed to Grafana"
  default     = "443"
}

variable "vpc-name" {
  type        = "string"
  description = "The name of the VPC to place resources on AWS. The EC2 instance will use a new security group within this VPC."
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
  description = "The name of the AWS key pair to use for the instance"
  default     = "TestEnvDockerHosts"
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

variable "vpc-security-group-id" {
  type        = "string"
  description = "ID of the security group, specifying inbound/outbound rules"
  default     = "sg-330c8549"
}
