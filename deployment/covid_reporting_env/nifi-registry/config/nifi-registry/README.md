# ReportingStack NiFi Registry

There is a place where you can place your custom files, which will be copied into nifi-registry working dir. These files will be moved the machine before the nifi-registry service start.

Basically, this solution allows loading already existing dump of nifi-registry. To do that we must placed here 2 directories:
* `database` - it contains definition of buckets and flows (with their UUID)
* `flow_storage` - it contains content of flows


These files can be obtained only from a running instance - files are deleted when the container is restarted. Steps of creating a nifi-registry dump:
1. Read nifi-registry container id
    ``` docker ps ```
2. Copy `database` and `flow_storage` directories to local machine (use read container id)
    ```
    docker cp <containerId>:/opt/nifi-registry/nifi-registry-0.2.0/database .
    docker cp <containerId>:/opt/nifi-registry/nifi-registry-0.2.0/flow_storage .
    ```

You can simply execute the whole operation by the following script

    export DOCKER_TLS_VERIFY="1" &&
    export DOCKER_HOST="<docker_url>:2376" &&                   # TODO: replace it
    export DOCKER_CERT_PATH="<docker_cert_absolute_path>" &&    # TODO: replace it
    NIFI_REGISTRY_IMAGE="apache/nifi-registry:0.2.0" &&         # TODO: check if this name is up-to-date
    BACKUP_DEST="." &&

    NIFI_REGISTRY_ID=$(docker ps -a -q --filter ancestor=$NIFI_REGISTRY_IMAGE) &&
    docker cp $NIFI_REGISTRY_ID:/opt/nifi-registry/nifi-registry-0.2.0/database $BACKUP_DEST &&
    docker cp $NIFI_REGISTRY_ID:/opt/nifi-registry/nifi-registry-0.2.0/flow_storage $BACKUP_DEST &&
    echo "Backup completed"
