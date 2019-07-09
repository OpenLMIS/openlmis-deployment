name = "casper-elmis"

bill-to = "Casper"

app-instance-ssh-user = "ubuntu"
app-instance-ssh-key-name = "CasperEnvDockerHost"

docker-ansible-dir = "../../../ansible/"

docker-tls-port = "2376"

app-dns-name = "casper-elmis.a.openlmis.org"
app-use-route53-domain = true
app-route53-zone-name = "a.openlmis.org"
aws-tls-cert-domain = "*.a.openlmis.org"

app-instance-group = "docker-hosts"

olmis-db-instance-class = ""
olmis-db-username = ""
olmis-db-password = ""
