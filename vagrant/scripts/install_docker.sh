#!/bin/bash -e

yum install -y \
  yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce-selinux-17.03.2.ce-1.el7.centos

systemctl enable docker && systemctl start docker

docker pull jenkins/jnlp-slave:latest
