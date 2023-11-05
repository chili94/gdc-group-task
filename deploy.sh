#!/bin/bash

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

