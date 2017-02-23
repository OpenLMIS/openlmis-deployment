# How to provision a docker swarm for deployment in AWS (With ELB)

## 1. Network setup

Create a VPC for the new swarm cluster.

In it, there should be 2 subnets created(which is needed by AWS ELB later).

Ensure the subnets will assign public ip to EC2 instances automatically, so it's easier to ssh into them later.

## 2. Create EC2 instances

This step is similar to creating EC2 instances for any other type of purpose.

When creating those instances, make sure to select the VPC created in the previous step.

Mentally mark one of the instances as swarm manager, the rest of them will be regular nodes.

**Note**: choose **ubuntu** instead of amazon linux distribution.
The amazon linux distribution has problems with docker 1.12, the version that has built in support for docker swarm. 1.12 is not available in amazon linux RPM yet.
And it also lacks support for aufs, which is recommended by docker.

**Make sure to open port 2376 insecurity group, this is the default port that docker-machine uses to provision.**

## 3. Add ssh public key to the newly created EC2 instances

In order to access the EC2 instances, the public key of **the machine from which the provisioning will happen** need to be added to the target machine.

This is done by ssh into the EC2 instances, and then edit `[User Home Dir]/.ssh/authorized_keys` file to add your public key into it.

This will be needed by the `docker-machine create` command later.

## 4. Create ELB

The reason to create ELB is that AWS has a limit on how many elastic ips each account could have, the default is 5, which could be easily used up.

So in order for the swarm to be available via a constant address, an ELB is created to provide that constant url.

This is also why in the first step, there need to be 2 subnets, it's required by ELB.

When creating the ELB, make sure **TCP port 22 and 2376** are forwarded to the target EC2 instance. 22 is for ssh, 2376 is for docker remote communication. 
And also, make sure to choose classic ELB instead of the new one. The classic one allows TCP forwarding, the new one only supports http and https.

## 5. Enable health check

ELB only forwards to a target machine if the target is considered "healthy".
And ELB determines the health of a target by pinging it.

So, in the EC2 instance chosen as the swarm manager, start apache2 service at port 80(or any other port you may prefer).
Then in ELB settings, set it to ping that port.
 
For OpenLMIS the Nginx container starts itself automatically after the system is rebooted, so this ensures that **ELB will start forwarding immediately if the instance reboots**.

## 6. Provision **all** EC2 instances

Use this command:

`docker-machine create --driver generic --generic-ip-address=[ELB Url] --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user ubuntu name1`

to provision the swarm manager.

**Note**: the --driver flag has support for AWS. But the intention to explicitly **_not_** use it is to make sure this provision step could apply to other host environments as well, not just AWS hosted machines.

The --generic-ip-address flag needs to be followed by the ip of ec2 instance(for the swarm manager, it should be the ELB Url).

The --generic-ssh-key flag needs to be followed private key, whose public key pair should have already been added in step 2.

The --generic-ssh-user flag needs to be followed by the user name, in the case of Ubuntu EC2 instances, the default user name is ubuntu.

Lastly, supply a **name** for the docker machine.

Do this **for all the EC2 instances**, to make sure docker is installed on all of them.
(When doing this for the none manager nodes, the --generic-ip-address flag should be followed by their public ip that was automatically assigned, since ELB only forwards traffic to the manager node.)

## 7. Start swarm

Choose one of the EC2 instances as the swarm manager by:

`eval $(docker-machine env [name of the chosen one])`
(the name in the [] should be one of the names used in the previous step)

Now your local docker command is pointing at the remote docker daemon, run:

`docker swarm init`

Then follow its console output to join the rest of the EC2 instances into the swarm.
(it could be done by switching docker-machine env, or by using the -H flag of docker, the former is easier)

Since all the swarm node are in the same VPC, they can talk to each other by private ips which are static inside the VPC.
**The swarm will regroup it self and maintain the manager-regular node structure even after EC2 instances are rebooted.**

## 8. Allow Jenkins to access swarm manager

In order for Jenkins to continuously deploy to the swarm, it needs access to the swarm manager.

In step 3, when the swarm manager EC2 instance was being provisioned. The docker-machine created some certificate files behind the scene.

Those files should be in the machine that the provision command was issued(not the machine that was being provisioned), under:

`[User Home Dir]/.docker/machine/machines/[name of the swarm manager]`

Those files need to be copied to jenkins.

In a Jenkins deployment job, **at the start of its build script**, add:

`export DOCKER_TLS_VERIFY="1"`

`export DOCKER_HOST="tcp://[ELB Url that forwards to Swarm manager]"`

`export DOCKER_CERT_PATH="[path to the dir that contains certs]"`

This will make following docker commands use the remote daemon, not the local one.

Now, Jenkins should be able to access and deploy to the swarm.
 
**Node**: Jenkins would only need access to the swarm manager, the other nodes are managed by the swarm manager. Jenkins does not need direct access to them.
