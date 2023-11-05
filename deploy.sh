#!/bin/bash

IMAGE_NAME="app-php"
# Define the initial version
BUILD_VERSION="1.0.1"

YOUR_DOCKERHUB_NAME="goran94hub"

docker pull "$YOUR_DOCKERHUB_NAME/$IMAGE_NAME:$BUILD_VERSION"
