#!/bin/bash
set -x
root=`pwd`
sudo mkdir -p $root/offline-repo/packages
sudo yum install wget -y
sudo yum install -y yum-utils
cd  $root/offline-repo
echo ######### installing local docker to create docker image tar #############
sudo wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.13.tgz
sudo tar -xvzf docker-20.10.13.tgz
sudo cp docker/* /usr/bin/
cd /usr/bin/ && sudo dockerd &> /dev/null &
sudo chown ec2-user:ec2-user /var/run/docker.sock && sudo chown ec2-user:ec2-user /usr/bin/docker
echo ######### downloading keepalived dependant packages #############
sudo yumdownloader --destdir=$root/offline-repo/packages/keepalived --resolve keepalived
sudo mkdir $root/offline-repo/packages/docker && cd $root/offline-repo/packages/docker
echo ######### downloading docker and docker-compose #############
sudo wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.13.tgz
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose
sudo chmod 777 docker-compose
sudo mkdir -p $root/offline-repo/images
cd $root/offline-repo/images
echo ######### pulling and saving vault image #############
sudo docker pull vault:1.10.0
sudo docker save vault:1.10.0 -o vault-1.10.0.tar
sudo chmod 777 vault-1.10.0.tar
sudo docker pull nginx:1.21.6-alpine
sudo docker save nginx:1.21.6-alpine -o nginx-1.21.6-alpine.tar
sudo chmod -R 777 $root/offline-repo/
