# How to provision a docker swarm for deployment in AWS

## 1. Create EC2 instances

This step is similar to creating EC2 instances for any other type of purpose.

**Note**: choose **ubuntu** instead of amazon linux distribution.
The amazon linux distribution has problems with docker 1.12, the version that has built in support for docker swarm. 1.12 is not available in amazon linux RPM yet.
And it also lacks support for aufs, which is recommended by docker.

### Make sure to open port 2376, this is the default port that docker-machine uses to provision.

## 2. Add ssh public key to the  newly created EC2 instances

In order to access the EC2 instances, the public key of **the machine from which the provisioning will happen** need to be added to the target machine.

## 3. Provision **all** EC2 instances

With this command:

`docker-machine create --driver generic --generic-ip-address=*.*.*.* --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user ubuntu name1`

**Note**: the --driver flag has support for AWS. But the intention to explicitly **_not_** use it is to make sure this provision guide could apply to any host machine, not just AWS hosted machines.

The --generic-ip-address flag needs to be followed by the ip of ec2 instance.

The --generic-ssh-key flag needs to be followed private key, whose public key pair should have already been added in step 2.

The --generic-ssh-user flag needs to be followed by the user name, in the case of Ubuntu EC2 instances, the default user name is ubuntu.

Lately, supply a **name** for the docker machine.

Do this **for all the EC2 instances**, to make sure docker is installed on all of them.

## 4. Start swarm

Choose one of the EC2 instances as the swarm manager by:

`eval $(docker-machine env [name of the chosen one])`
(the name in the [] should be one of the names used in the previous step)

Now your local docker command is pointing at the remote docker daemon, run:

`docker swarm init`

Then follow its console output to join the rest of the EC2 instances into the swarm.
(it could be done by switching docker-machine env, or by using the -H flag of docker, the former is easier)

## 5. Allow Jenkins to access swarm manager

In order for Jenkins to continuously deploy to the swarm, it needs access to the swarm manager.

In step 3, when the swarm manager EC2 instance was being provisioned. The docker-machine created some certificate files behind the scene.

Those files should be in the machine that the provision command was issued(not the machine that was being provisioned), under:

`[User Home Dir]/.docker/machine/machines/[name of the swarm manager]`

Those files need to be copied to jenkins(if the provision was done on Jenkins, then there is no need to copy).

In a Jenkins deployment job, **at the start of its build script**, add:

`export DOCKER_TLS_VERIFY="1"`
`export DOCKER_HOST="tcp://[ip of the swarm manager]"`
`export DOCKER_CERT_PATH="[path to the dir that contains certs]"`

This will make following docker commands use the remote daemon, not the local one.

Now, Jenkins should be able to access and deploy to the swarm.
 
**Node**: Jenkins would only need access to the swarm manager, the other nodes are managed by the swarm manager. Jenkins does not need direct access to them.
