# BIg Data Service stack
This terraform scripts allow to user provision stack of OCI resources needed for Big Data Service, including service itself.
In order to provision it, user have to follow steps:
1) Provision some client compute instance in OCI (this instance can be removed after terraform scrips finish it work)
2) ssh to this host, like this:
ssh -i myPrivateKey opc@<ip address>
3) Install git:
$ sudo yum install -y git
4) clone terrform repository:
$ git clone https://github.com/filanovskiy/terraform-oci-bds.git
5) go to repository dir and init terraform provider:
cd  terraform-oci-bds
terraform init
6) after this user have to fill up enviroment varibles in env-vars.sh:
Note: you may want to generate ssh key pair. Here is some references on how to
7) apply this enviroment varibles:
source env-vars.sh
8) Run provisioning:
terraform apply -auto-approve