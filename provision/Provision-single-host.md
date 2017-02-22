If case the deployment target is one single host, then swarm is not needed.

In that case, refer to Provision-swarm-With-Elastic-ip.md for step 1, 2, 3, 5.
Omit step 4, that should be sufficient to provision a single host deployment environment.

**Note**: choose **ubuntu** instead of amazon linux distribution.
Even though this single host won't be running a swarm, ubuntu is still preferred over amazon linux distribution.
Because docker-machine does not support provisioning amazon linux distribution.
However, you can manually provision the single host, but then making that host remotely accessible would be tricky and involves a lot of manual steps.


## Database

If deploying OpenLMIS with the included Docker Container for Postgres, then no further steps are needed.  However this setup
is recommended only for development / testing environments and not recommended for production installs.

Test and UAT environments in this repository demonstrate that Postgres could be installed outside of Docker and OpenLMIS 
services may be pointed to that Postgres server.  Test and UAT both use Amazon's RDS service to help manage production-grade
database services such as automated patch release updates, rolling backups, snapshots, etc.

Some notes on provisioning an RDS instance for OpenLMIS:

* Test and UAT are both capable of running on economical RDS instances:  db.t2.micro
* When choosing a small RDS instance, the max number of connections are set based on an *ideal* number from RDS.  OpenLMIS services
tend toward using about 10 DB connections per service.  Therefore Tests and UAT instances use a Parameter Group named Max Connections
that increase this limit to 100.  Larger, more expensive, instances likely won't have this limitation.
* RDS instances are in a private VPC and in the same availability zone as their EC2 instance and it's ELB.  The security group used
should be the same as used for the EC2 instance, though it should limit incoming PostgreSQL connections to only those from the security
group.
* Don't forget to update the .env file used to deploy OpenLMIS with the correct Host, username and password settings.
