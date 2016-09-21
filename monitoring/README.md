This is for setting up docker containers monitor.

The compose file was taken from https://github.com/vegasbrianc/prometheus and modified.

So please read this first: https://github.com/vegasbrianc/prometheus/blob/version-2/README.md

# Currently existing monitor

http://52.52.3.5:3000/dashboard/db/test-docker-host

http://52.52.3.5:3000/dashboard/db/uat-docker-host

This is running in both test and UAT envs. But the web UI is exposed from UAT.

# How to add another env into the monitor

curl -s https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/monitoring/start_monitor.sh | bash