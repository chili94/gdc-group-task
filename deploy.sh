#!/bin/bash

#set -xe

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Read the IMAGE_NAME from the command line
read -p "Enter the IMAGE_NAME which you would like to deploy (e.g., app-php): " IMAGE_NAME

# Read the BUILD_VERSION from the command line
read -p "Enter the BUILD_VERSION (e.g., 1.0.1 or latest): " BUILD_VERSION

# Read the YOUR_DOCKERHUB_NAME from the command line
read -p "Enter your Docker Hub username: " YOUR_DOCKERHUB_NAME

if docker image inspect "$YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION" &> /dev/null; then
  echo "Docker image "$YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION" already exists locally."
else
  # If the image is not found locally, pull it from Docker Hub
   docker pull "$YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION"
fi

TERRAFORM_DIR="terraform"

check_terraform() {
  if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Making instalation..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
  else
    echo "Terraform is installed."
  fi
}

check_kubectl() {
  if ! command -v kubectl version &> /dev/null; then
    echo "kubectl is not installed. Making instalation..."
    sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    sudo echo "$(<kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/bin/kubectl
    sudo rm -rf kubectl && rm -rf kubectl.sha256
  else
    echo "Kubectl is installed."
  fi
}

check_eksctl() {
  if ! command -v eksctl &> /dev/null; then
    echo "eksctl is not installed. Making instalation..."
    sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo sudo mv /tmp/eksctl /usr/bin
    eksctl version
  else
    echo "Eksctl is installed."
  fi
}

terraform_init() {
  cd "$TERRAFORM_DIR" || exit
  terraform init
  cd ..
  echo "Terraform initialization complete."
}

terraform_validate() {
  cd "$TERRAFORM_DIR" || exit
  terraform validate
  cd ..
  echo "Terraform configuration is valid."
}

terraform_plan() {
  cd "$TERRAFORM_DIR" || exit
  terraform plan
  cd ..
  echo "Terraform planning complete."
}


terraform_apply() {
  cd "$TERRAFORM_DIR" || exit
  terraform apply -auto-approve
  cd ..
  echo "Terraform apply complete."
}


eks_configuration() {
  cd "$TERRAFORM_DIR" || exit
  VPC_ID=$(terraform output -json client_vpc)
  SUBNET_A=$(terraform output -json client_subnet_a)
  SUBNET_B=$(terraform output -json client_subnet_b)
  cd ..
}





#Install kubctl
check_kubectl


echo "Preparing terraform"
sleep 2

#Check if Terraform is installed
check_terraform

#Initialize Terraform
terraform_init

#Validate the Terraform configuration
terraform_validate

#Terraform plan
terraform_plan

read -p "Do you want to apply these changes? (yes/no): " confirm
if [ "$confirm" == "yes" ]; then
  terraform_apply
else
  echo "Aborted. No changes have been applied."
  exit 1
fi


echo "Preparing configuration for EKS cluster"
sleep 2


#Configure EKS Cluster
eks_configuration


EKS_YAML_FILE="eks/cluster.yaml"
EKS_DEPLOY_YAML_FILE="eks-deploy/app.yaml"

#replace the VPC ID and subnet values in the YAML file
sed -i -e "s/id:.*/id: $VPC_ID/; /vpc_id/d; s/public-one:.*/public-one:\n        id: $SUBNET_A/; s/public-two:.*/public-two:\n        id: $SUBNET_B/" $EKS_YAML_FILE

# Comment out entry below public-one:
sed -i '/public-one:/{:a;N;/id:/{N;s/id:/# id:/2};ba}' $EKS_YAML_FILE

# Comment out entry below public-two:
sed -i '/public-two:/{:a;N;/id:/{N;s/id:/# id:/2};ba}' $EKS_YAML_FILE


#Install eksctl
check_eksctl
sleep 2

#Create EKS Cluster
eksctl create cluster -f $EKS_YAML_FILE

#Connect to the Cluster
aws eks update-kubeconfig --region us-east-1 --name cluster-eks3

#adding image to the deplyment
sed -i -e "/containers:/a\ \ \ \ \ \ - name: app-php\n\ \ \ \ \ \ \ \ image: $YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION" "$EKS_DEPLOY_YAML_FILE"
sleep 2

#Deploy section
INGRESS_CONTROLLER_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml"
INGRESS_YAML="eks-deploy/ingress.yaml"
APP_YAML="eks-deploy/app.yaml"

kubectl apply -f "$INGRESS_CONTROLLER_URL"
sleep 2
kubectl apply -f "$INGRESS_YAML"
sleep 2
kubectl apply -f "$APP_YAML"

sleep 10
kubectl_output=$(kubectl get svc)
external_ip=$(echo "$kubectl_output" | awk 'NR>1 && $4 != "<none>" {print $4}')

if [ -z "$external_ip" ]; then
    echo "No valid External IP found."
else
    # Print the External IP with the desired message
    echo "APP is ready on URL: $external_ip and use port 8080 with HTTP protocol"
fi













