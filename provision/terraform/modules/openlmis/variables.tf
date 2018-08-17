variable "name" {
  type        = "string"
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

variable "docker-https-port" {
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
