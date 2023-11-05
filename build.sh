#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Check if AWS CLI is configured
if ! aws s3 ls >/dev/null 2>&1; then
  echo "AWS CLI is not configured. Please run 'aws configure' to set up AWS CLI. Please use 'us-east-1' region "
  exit 1
else
  echo "AWS CLI is configured."
fi

check_docker() {
  if ! command -v docker --version &> /dev/null; then
    echo "Docker is not installed. Making instalation..."
    sudo yum update -y
    sudo yum install docker -y
    sudo systemctl start docker
  else
    echo "Docker is installed."
  fi
}

AWS_VERSION=$(aws --version | awk -F/ '{print $2}')
MAJOR_VERSION=$(echo "$aws_version" | cut -d. -f1)
REQUIRED_MAJOR_VERSION="2"

if [[ "$MAJOR_VERSION" < "$required_version" ]]; then
  echo "AWS CLI version is lower than $required_version. Updating AWS CLI..."
  # Update the AWS CLI to version 2
   sudo yum remove awscli -y
   sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   sudo unzip awscliv2.zip
   sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/bin/aws-cli --update
   sudo rm -rf aws && rm -rf awscliv2.zip
   sudo aws --version
  echo "AWS CLI has been updated to version 2."
else
  echo "AWS CLI version is already $aws_version, no update needed."
fi

#Checking docker
check_docker

if [ -e "$HOME/.docker/config.json" ]; then 
 echo "User is logged in to a Docker Hub account."
else
  echo "User is not logged in to a Docker Hub account. Type 'docker login' and use your own credentials"
  exit 1
fi

BUILD_CONTENT="./app"

# Read the IMAGE_NAME from the command line
read -p "Enter the IMAGE_NAME (e.g., app-php): " IMAGE_NAME

# Read the BUILD_VERSION from the command line
read -p "Enter the BUILD_VERSION (e.g., 1.0.1 or latest): " BUILD_VERSION

# Read the YOUR_DOCKERHUB_NAME from the command line
read -p "Enter your Docker Hub username: " YOUR_DOCKERHUB_NAME


docker build -t "$YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION" "$BUILD_CONTENT"

docker login

docker push "$YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION"

if [ $? -eq 0 ]; then
    echo "Image successfully built and pushed to Docker Hub."
    export docker_hub=$YOUR_DOCKERHUB_NAME
else
    echo "Failed to build and push the image to Docker Hub."
fi






