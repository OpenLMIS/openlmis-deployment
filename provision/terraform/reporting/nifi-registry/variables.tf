variable "nr-instance-type" {
  type        = "string"
  description = "AWS instance type for the NiFi Registry host"
}

variable "nr-volume-size" {
  type        = "string"
  description = "The size in GB of the root block device fro the NiFi Registry host"
}

variable "nr-ssh-key" {
  type        = "string"
  description = "The SSH public key to copy over to the NiFi Registry host"
}

variable "nr-name" {
  type        = "string"
  description = "The name tag to give the NiFi Registry host"
}

variable "env" {
  type        = "string"
  description = "The environment the set of AWS resources are being provisioned for"
}

variable "bill-to" {
  type        = "string"
  description = "Which project to bill the provisioned resources"
}

variable "nr-http-port" {
  type        = "string"
  description = "The HTTP port NiFi Registry runs on"
}

variable "nr-https-port" {
  type        = "string"
  description = "The HTTPS port NiFi Registry runs on"
}

variable "nr-subnet-id" {
  type        = "string"
  description = "ID of sububnet the NiFi Registry host should be in"
}

variable "nr-ami" {
  type        = "string"
  description = "The AMI to use with the NiFi Registry instance"
}

variable "nr-vpc-name" {
  type        = "string"
  description = "The name of the VPC to place NiFi Registry resources on AWS"
}

variable "nr-instance-group" {
  type        = "string"
  description = "The deployment group to place the NiFi Registry host. Will dictate what Ansible playbooks can ran on it"
}

variable "nr-instance-ssh-user" {
  type        = "string"
  description = "The name of the user to connect as in the NiFi Registry host"
}

variable "docker-ansible-dir" {
  type        = "string"
  description = "The path to the directory containing the playbook for installing docker"
}

variable "nr-dns-name" {
  type        = "string"
  description = "The DNS name associated to NiFi Registry"
}

variable "nr-tls-s3-access-key-id" {
  type        = "string"
  description = "The AWS access key ID to use to backup generated Docker TLS files"
}

variable "nr-tls-s3-secret-access-key" {
  type        = "string"
  description = "The AWS secrect access key to use to backup generated Docker TLS files"
}

variable "docker-https-port" {
  type        = "string"
  description = "The TCP port The Docker Daemon is listening for TLS traffic"
}
