# Getting Started

Before you begin, make sure you have the following prerequisites:

- [Git](https://git-scm.com/) installed on your system.
- An [AWS](https://aws.amazon.com/) account.
- A [DockerHub](https://hub.docker.com/) account.

### System Requirements

- **Operating System:** Amazon Linux 2
- **CPU:** 2
- **RAM:** 2GB

# Application Setup

1. The original app content is pulled from  [banago/simple-php-website](https://github.com/banago/simple-php-website).

2. Clone the app content from [gdc-group-task](https://github.com/chili94/gdc-group-task) repository.

3. Run the `./build.sh` script from the `gdc-group-task` repository. This script will prompt you for the following information:
   - Image name
   - Tag
   - DockerHub username
   Feel free to rerun the script if you need to add or modify any configuration. The script will install all necessary dependencies required for building and pushing the image.

4. Once the `./build.sh` script is complete, and you want to deploy the image you pushed to DockerHub, run the `./deploy.sh` script from the `gdc-group-task` repository. This script will also ask for the following information:
   - Image name
   - Tag
   - DockerHub user
   You can provide any image that you have already built using the `./build.sh` script.

5. When the `./deploy.sh` script is finished, you will receive an APP-URL. After waiting for 2-3 minutes for propagation time, you will be able to connect to the mentioned APP-URL on port 8080.

# Accessing Your Application

Access your deployed application by navigating to the provided APP-URL with port 8080.

