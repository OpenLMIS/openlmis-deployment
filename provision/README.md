# How to provision a docker swarm for deployment in AWS

## 1. Create EC2 instances

This step is similar to creating EC2 instances for any other type of purpose.

Note: choose **ubuntu** instead of amazon linux distribution.
The amazon linux distribution has problems with docker 1.12, the version that has built in support for docker swarm. And it also lacks support for aufs, which is recommended by docker.

### Make sure to open port 2376, this is the default port that docker-machine uses to provision.

## 2. Add ssh public key to the  newly created EC2 instances

In order to access the EC2 instances, the public key of the machine from which the provisioning will happen need to be added to the target machine.

## 3. Provision **all** EC2 instances

With this command:

`docker-machine create --driver generic --generic-ip-address=*.*.*.* --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user ubuntu whatever_name`

Note: the --driver flat has support for AWS. But the intention to explicitly **_not_** use it is to make sure this provision guide could apply to any host machine, not just AWS hosted machines.

The --generic-ip-address flag needs to be followed by the ip the ec2 instance ip.

The --generic-ssh-key flag needs to be followed by your private key, whose public key pair should have already been added in step 2.

The --generic-ssh-user flag needs to be followed by the user name, in the case of Ubuntu EC2 instances, the default user name is ubuntu.

Lately, supply a **name** for the docker machine. With this name, the provision machine will retain access to the remote host.

Do this for all the EC2 instances, to make sure docker is installed on all of them.

## 4. Start swarm

Choose one of the EC2 instances as the swarm manager by:

`eval $(docker-machine env [name of the chosen one])`
(the name in the [] should be one of the names used in the previous step)

Now your local docker command is pointing at the remote docker daemon, run:

`docker swarm init`

Then follow its console output to join the rest of the EC2 instances into the swarm.
(it could be done by switching docker-machine env, or by using the -H flag of docker, the former is easier)