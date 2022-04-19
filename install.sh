#!/bin/bash
set -x
repo_dir=$1
pem_key=$2
username="ec2-user"
lines=($(cat infra-setup.properties))
for line in "${lines[@]}"; do
  key=`echo $line | cut -d "=" -f 1`
  value=`echo $line | cut -d  "=" -f 2`
  export $key=$value
##copy docker tar
  scp -i $pem_key ${repo_dir}/packages/docker/docker-20.10.13.tgz $username@${value}:/tmp/
##copy docker-compose binary
  scp -i $pem_key ${repo_dir}/packages/docker/docker-compose  $username@${value}:/tmp/
##copy keepalived and install
  scp -i  $pem_key -r ${repo_dir}/packages/keepalived  $username@${value}:/tmp/
  ssh -i $pem_key $username@${value} "cd /tmp/keepalived/ && sudo rpm -ivh *"
##install docker
  ssh -i $pem_key $username@${value} "if  docker --version | grep build | grep version; then echo exists; else cd /tmp/ && tar -xvzf docker-20.10.13.tgz && sudo cp /tmp/docker/* /usr/bin/; fi"
  ssh -i $pem_key $username@${value} "if docker ps | grep \"Cannot connect\"; then echo 1; else cd /usr/bin/ && sudo dockerd; fi"
  ssh -i $pem_key $username@${value} "if  docker --version | grep build | grep version; then sudo chown $username:$username /var/run/docker.sock && sudo chown $username:$username /usr/bin/docker; fi"
##install docker compose
  ssh -i $pem_key $username@${value} "sudo cp /tmp/docker-compose /usr/bin/ && docker-compose --version"
  ssh -i $pem_key $username@${value} "sudo chown $username:$username /usr/bin/docker-compose"
## copy docker images
  scp -i $pem_key ${repo_dir}/images/*.tar  $username@${value}:/tmp/
  ssh -i $pem_key $username@${value} "cd /tmp/ && sudo docker load -i vault-1.10.0.tar && docker load -i nginx-1.21.6-alpine.tar"
done
