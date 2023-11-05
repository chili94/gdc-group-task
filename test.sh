#!/bin/bash

set -xe


check_kubectl() {
  if ! command -v kubectl version --client &> /dev/null; then
    echo "Kubectl is not installed. Making instalation..."
    sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.6/2023-10-17/bin/linux/amd64/kubectl
    sudo chmod +x kubectl
    sudo mv kubectl /usr/bin/
    sudo kubectl version --client
  else
    echo "kubectl is installed."
  fi
}

check_kubectl

#Connecting kubectl with eks cluster
aws eks update-kubeconfig --region us-east-1 --name cluster-eks3
