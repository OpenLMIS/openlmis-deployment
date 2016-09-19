If case the deployment target is one single host, then swarm is not needed.

In that case, refer to Provision-swarm-With-Elastic-ip.md for step 1, 2, 3, 5.
Omit step 4, that should be sufficient to provision a single host deployment environment.

**Note**: choose **ubuntu** instead of amazon linux distribution.
Even though this single host won't be running a swarm, ubuntu is still preferred over amazon linux distribution.
Because docker-machine does not support provisioning amazon linux distribution.
However, you can manually provision the single host, but then making that host remotely accessible would be tricky and involves a lot of manual steps.
