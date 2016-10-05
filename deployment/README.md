Scripts in this directory are meant to be ran in Jenkins.

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

1.  ssh into the docker host that you want, either test env or UAT env.  Or use the technique above to connect your docker client to the remote host as needed

2.  run this command

    `docker exec -t [PostgresContainerName] /usr/lib/postgresql/9.4/bin/pg_dumpall -c -U [DBUserName] > [DumpFileName].sql`
    
    **PostgresContainerName** is usually testenv_db_1 or uatenv_db1, you can use `docker ps` to find out.
    **DBUserName** is the one that was specified in the .env file, it's usually just "postgres".
    **DumpFileName** is the file name where you want the back up to be stored **in the host machine**.
    
