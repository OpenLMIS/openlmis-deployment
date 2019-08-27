# Casper Provisioning

The configuration files here create Amazon Web Services (AWS) resources for three (virtual) machines for the Casper pipeline.
 * `elmis/` defines one machine, which is used to run eLMIS and the Casper pipeline.
 * `v3/` defines a machine for running OpenLMIS version 3.
 * `nifi/` defines a machine for the version 3 reporting stack and the NiFi registry that it depends on. (There is an additional NiFi instance that runs as part of the Casper pipeline, but it does not use the NiFi registry that runs here).

## Maintaining these resources

1. To adjust the configurations here, you'll need to install terraform and ansible and set up AWS credentials. Follow the [general setup instructions](../README.md)

2. Make your desired edits to a `terraform.tfvars` file, or any other.

3. In one of the subdirectories (`elmis/`, `v3/`, `nifi/`), prepare terraform:
```
$ terraform init
```

4. To see the effect of your changes, run:
```
$ terraform plan
```

5. To apply your changes, run:
```
$ terraform apply
```

## AWS Resource Dependencies

In addition to the AWS resources defined in the code here, some additional resources are needed. These have already been created for the Casper demo servers described here.

* A Route 53 zone in which to register subdomains. The variable `app-route53-zone-name` points to this.
* A TLS certificate for the above zone. `aws-tls-cert-domain` points to this.
* An EC2 key pair. `app-instance-ssh-key-name` points to this.
* A Virtual Private Cloud (VPC), with a security group (pointed to by `vpc-security-group-id`) that opens the following ports:
  - 80
  - 5432
  - 8080
  - 8888
  - 8083
  - 8000
  - 21
  - 22
  - 2376
  - 9090
  - 3000
  - 443
  This manually-configured security group is used by the eLMIS and OpenLMIS servers, but the NiFi registry and reporting stack have their own security group, managed by terraform via `../modules/nifi-registry/network.tf`.

## Resources Created Here

### eLMIS

`elmis/` defines:
* An Elastic Load Balancer (ELB)
* A Route 53 DNS record for `casper-elmis.a.openlmis.org`, pointing to the load balancer
* An EC2 instance, with docker installed, behind the load balancer

### OpenLMIS v3

`v3/` defines:
* An Elastic Load Balancer (ELB)
* A Route 53 DNS record for `casper.a.openlmis.org`, pointing to the load balancer
* An EC2 instance, with docker installed, behind the load balancer
* A Relational Database Service (RDS) running PostgreSQL

### OpenLMIS v3 Reporting

`nifi/` defines:
* An Elastic Load Balancer (ELB)
* Route 53 DNS records for `casper-nifi-registry.a.openlmis.org` and `casper-superset.a.openlmis.org`, both pointing to the load balancer
* An EC2 instance, with docker installed, behind the load balancer
* An elastic IP address for the EC2 instance
