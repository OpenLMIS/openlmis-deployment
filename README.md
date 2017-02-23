# openlmis-deployment
Scripts for provisioning and deployment of OpenLMIS v3.  This repository holds specific tools for managing OpenLMIS test (CI)
and UAT deployments, as well as lays out a general recipe for deploying OpenLMIS.

## Recommended deployment topology

OpenLMIS uses and therefore can easily recommend that most deployments utilize Amazon Web Services (AWS).  However OpenLMIS is in no way
tied to only being deployed on AWS.

The basic ingredients of an OpenLMIS deployment are:
* a domain name to reach the installation at (e.g. test.openlmis.org)
* a SSL certificate to make the communication to OpenLMIS secure over the web
* a computer/instance/etc that can run Docker Machine (as well as Compose, etc) with enough bandiwdth, processing power, memory and 
storage to run many (6+) Services and associated utilities
* a computer/instance/etc that can run PostgreSQL for those Services

In AWS this would look like:
* A DNS provider for your domain name (e.g. test.openlmis.org).  This could be Route 53, however currently OpenLMIS deployments do 
not utilize this service.
* A SSL certificate from AWS Certificate Manager
* A ELB that can route to/from the OpenLMIS instance and serve the ACM SSL certificate (this becomes more useful when running out 
of Elastic IPs)
* an EC2 Instance (m4.large - 2VPU, 8GiB memory, 30GB EBS store)
* an RDS Instance (you could start with the smallest one, and then upgrade based on need)
* a VPC for your EC2 and RDS instances, with appropriate security group - SSH, HTTP, HTTPs, Postgres (limit source to Secuurity Group)
at minimum.

For more information on setting this up, see the [Provisioning](provision/Provision-single-host.md) section and also follow the 
link for backing up/restoring [RDS](deployment#using-amazons-rds)
