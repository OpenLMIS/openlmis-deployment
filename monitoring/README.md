**Note**:  The usage of this section no longer applies in our current Test and UAT environments.  A number of reasons factor into this
decision to not utilize this monitoring setup for the time being, including:
* Full configuration / learning curve was not realized
* Prometheus / Grafana containers were taking up significant system resources leading to high memory usage, high disk latency and 
sizeable CPU usage.
* Existing infrastructure, Scalyr, is being used for instance/docker monitoring for many other OpenLMIS projects

# Monitoring

This section is preserved in-case we'd like to re-deploy Prometheus / Grafana.

This is for setting up docker monitor.

The compose file was taken from https://github.com/vegasbrianc/prometheus and modified.

So please read this first: https://github.com/vegasbrianc/prometheus/blob/version-2/README.md

# Currently existing monitor

http://uat-env-elb-1284865908.us-east-1.elb.amazonaws.com:3000/dashboard/db/test-docker-host

http://uat-env-elb-1284865908.us-east-1.elb.amazonaws.com:3000/dashboard/db/uat-docker-host

This is running in both test and UAT envs. But the web UI is exposed from UAT.

It's configured to automatically restart, so you don't have to worry about system reboot.

# How to add another docker host into the monitor

1.  ssh into the docker host that you want to monitor, find or create a suitable directory, then run:

    `curl -s https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/monitoring/start_monitor.sh | bash`

    This is the only script that needs to be run.

2.  Make sure the host machine you want to monitor has its port 9090 open to the UAT machine's ip. This is needed in the next step. 

3.  Go to: http://uat-env-elb-1284865908.us-east-1.elb.amazonaws.com:3000/datasources, add a new data source for the new host machine. 
    You can look at the existing ones for example. If you need credentials, please ask Josh to assign it for you. 
    Then add a new Dashboard for it for the newly created data source.

That should be it.
