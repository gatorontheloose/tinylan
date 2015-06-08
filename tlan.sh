#!/bin/bash
set -x

##
#
# tlan.sh
# simluates 2 un-connected host and 1 master host in docker
#
# tlan <number>  where 0 is the master, 1,2,....,10 are the clients
#
#


##
#
# user account in Dockerfile
#
#
  user=root


##
#
# ssh key from Dockerfile
#
#
  identityfile=$(dirname `readlink -e $0`)/keys/id_rsa

##
#
# Docker
#
#
  prefix="tlan"
  master_hostname="host"


##
#
# If no key exists, create one & rebuild the base image to include it
#
#
[[ ! -f ${identityfile} ]] || [[ ${1} == "build" ]] && \
  ( yes | ssh-keygen -q -N "" -f ${identityfile} && docker build -t sshd .) && exit 0


##
#
# 'stop' as first arg will stop all or the 2nd arg's name
#
#
([[ ${1} = "stop" ]] && [[ $(docker rm -f $(docker ps -aq --filter "name=${prefix}")) ]]) && docker ps -a && exit 0


##
#
# no args means we want the host, otherwise add the host link
#
#
([[ $# = 0 ]] && (name=${prefix}.${master_hostname})) || \
  linking="--link ${prefix}.${master_hostname}:${master_hostname}" && \
  name=${1}


##
#
# Run the docker image
#
#
uuid=$(docker run -d ${linking} --name $prefix.${name} sshd)


##
#
# ssh to the docker image
#
#
ip=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $uuid)
ssh -o StrictHostKeyChecking=no ${user}@${ip} -i ${identityfile}
