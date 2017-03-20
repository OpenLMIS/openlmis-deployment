Scripts in this directory are meant to be ran in Jenkins.

# Overview

* `shared/` contains scripts for the Jenkins job(s):
  * `init_env.sh` is run in Jenkins to copy the docker environment files (has secure credentials) from `JENKINS_HOME/credentials/` to the current job's workspace
  * `pull_images.sh` always pulls/refreshes the infrastructure images (e.g. db, logs, etc), and then at the end will pull the image for the service that the Jenkins job is attempting to deploy (e.g. requistion, auth, referencedata, etc).
  * `restart.sh` is paramartized by Jenkins to either `keep` or `wipe` volumes (e.g. database and logging volumes).  When run this brings the deployed reference distribution down, and then back up.  After it's brought up, the `nginx.tmpl` file is copied directly into the running nginx container just started.
  * `nginx.tmpl` is the override of the nginx template for docker and proxying - this is a copy from [openlmis-ref-distro](http://github.com/openlmis/openlmis-ref-distro).  See `restart.sh` for how it's used.
* `test_env` has a compose file which is the Reference distribution, and a script for Jenkins to kick everything off.
* `uat_env` has a compose file which is the Reference distribution, and a script for Jenkins to kick everything off.
* `demo_env` has a compose file which is the latest stable version of the Reference distrubution, and a script for Jenkins to kick everything off.

# Local Usage

These scripts **won't** work out of the box in a dev's local machine, to make them work, you need a few files that are present in Jenkins but not in your local clone of this repo:

1.  The .env file

    This file is present in Jenkins. It is copied to the workspace of a deployment job(either Jenkins slave or master) every time that job is ran.

    This file is **not** included in this repo because the db credentials could be different for different deployment environments. The default .env file that is used during development and CI is open in github, making it not suitable for deployment purposes. 

2.  The cert files for remotely controlling docker daemon deployment target

    These files should not be included in this public repo for obvious reasons.
    
    Similar to the .env file, they are also present in Jenkins and copied to a deployment job's workspace(either Jenkins slave or master) every time it is ran.
     
To get these files, you need to be able to ssh to the Jenkin's host instance.

It's **not** recommended that you connect to the remote deployment environments, however if you have to:

1. pull the remote cert files to a local directory.  They are currently located under `JENKINS_HOME/credentials/` in the `Host` directories.  `JENKINS_HOME` would currently be `/var/lib/jenkins`.

2. With the above cert files, you could control the remote docker machine by copying the certs to a local `certs/` directory, and then running the following in your shell:

  ```
  export DOCKER_TLS_VERIFY="1"
  export DOCKER_HOST="tcp://<path-to-elb-of-docker-host>:2376"
  export DOCKER_CERT_PATH="${PWD}/certs"
  ```
  e.g. a current elb path for test is `elb-test-env-swarm-683069932.us-east-1.elb.amazonaws.com`

  After this, running docker commands in your shell will be ran against the remote machine.  e.g. docker inspect, logs, etc


# How to backup persisted data?

## if using ref distro's included db container
1.  ssh into the docker host that you want, either test env or UAT env.  Or use the technique above to connect your docker client to the remote host as needed

2.  run this command

    `docker exec -t [PostgresContainerName] /usr/lib/postgresql/9.4/bin/pg_dumpall -c -U [DBUserName] > [DumpFileName].sql`
    
    **PostgresContainerName** is usually testenv_db_1 or uatenv_db1, you can use `docker ps` to find out.
    **DBUserName** is the one that was specified in the .env file, it's usually just "postgres".
    **DumpFileName** is the file name where you want the back up to be stored **in the host machine**.
    
## using Amazon's RDS

RDS provides a number of desirable features that are more ideal for production environments, including automated backups.  To backup and
restore the OpenLMIS database when using RDS, follow Amazon's documentation:  http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_CommonTasks.BackupRestore.html
