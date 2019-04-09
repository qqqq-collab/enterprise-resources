#!/bin/bash -e

if [ ! -e /etc/kubernetes/admin.conf ]; then

  if [ ! -e /etc/sysctl.d/50-kubernetes ]; then
    echo "net.bridge.bridge-nf-call-iptables = 1" > /etc/sysctl.d/50-kubernetes
    sysctl -w net.bridge.bridge-nf-call-iptables=1
  fi

  if grep swap /etc/fstab &> /dev/null; then
    grep -v swap /etc/fstab > /etc/fstab.tmp && mv /etc/fstab.tmp /etc/fstab
    swapoff -a
  fi

  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

  setenforce 0

  yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

  systemctl enable kubelet && systemctl start kubelet

  kubeadm init --pod-network-cidr=10.244.0.0/16

  if ! grep KUBECONFIG /root/.bashrc &> /dev/null; then
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc
  fi

  # shellcheck disable=SC1091
  source /root/.bashrc

  kubectl apply -f \
    https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

  kubectl taint nodes --all node-role.kubernetes.io/master-

  if [ ! -e "/etc/sysctl.d/40-br-iptables.conf" ]; then
    echo "net.bridge.bridge-nf-call-iptables = 1" > /etc/sysctl.d/40-br-iptables.conf
  fi
fi
