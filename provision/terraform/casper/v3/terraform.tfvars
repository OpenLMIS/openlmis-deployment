name = "casper"

bill-to = "Casper"

app-instance-ssh-user = "ubuntu"
app-instance-ssh-key-name = "CasperEnvDockerHost"

docker-ansible-dir = "../../../ansible/"

docker-tls-port = "2376"

app-dns-name = "casper.a.openlmis.org"
app-use-route53-domain = true
app-route53-zone-name = "a.openlmis.org"
aws-tls-cert-domain = "*.a.openlmis.org"

app-instance-group = "docker-hosts"

olmis-db-instance-class = "db.t2.medium"
olmis-db-username="pHvNEhePnLpdATZe"
olmis-db-password="xkRFqrFD6qSq7wjH"

vpc-security-group-id="sg-0ac523a643cead168"