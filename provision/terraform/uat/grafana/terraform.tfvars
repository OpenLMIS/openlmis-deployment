name = "grafana"

bill-to = "OpenLMIS"

vpc-name = "JunkDrawerVPC"

app-instance-ssh-user = "ubuntu"
app-instance-ssh-key-name = "TestEnvDockerHosts"
docker-ansible-dir = "../../../ansible/"

docker-tls-port = "2376"

app-dns-name = "grafana.a.openlmis.org"
app-use-route53-domain = true
app-route53-zone-name = "a.openlmis.org"
aws-tls-cert-domain = "*.a.openlmis.org"

app-instance-group = "docker-hosts"
