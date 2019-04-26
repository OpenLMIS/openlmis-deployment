variable "name" {
  type = "string"
  description = "Name of the environment"
}

variable "app-instance-ssh-user" {
  type        = "string"
  description = "The name of the user to connect as in the app host"
}

variable "docker-ansible-dir" {
  type        = "string"
  description = "The path to the directory containing the playbook for installing docker"
}

variable "docker-tls-port" {
  type        = "string"
  description = "The TCP port The Docker Daemon is listening for TLS traffic"
}

variable "aws_access_key_id" {
  type        = "string"
  description = "The AWS access key ID to use to backup generated Docker TLS files"
}

variable "aws_secret_access_key" {
  type        = "string"
  description = "The AWS secrect access key to use to backup generated Docker TLS files"
}

variable "app-dns-name" {
  type        = "string"
  description = "The DNS name associated to the app instance"
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

