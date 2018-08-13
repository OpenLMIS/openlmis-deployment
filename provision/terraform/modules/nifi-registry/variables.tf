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
  type = "string"
  description = "ID of subnet the NiFi Registry host should be in"
}
variable "nr-ami" {
  type = "string"
  description = "The AMI to use with the NiFi Registry instance"
}

variable "nr-vpc-name" {
  type = "string"
  description = "The name of the VPC to place NiFi Registry resources on AWS"
}
