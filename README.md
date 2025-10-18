# Amazon Q CLI in Docker on AWS EC2

This guide explains how to set up Amazon Q CLI in a Docker container on an AWS EC2 instance running Ubuntu.

## Prerequisites

- AWS EC2 instance running Ubuntu
- Docker installed on the EC2 instance
- AWS credentials configured (if you plan to use AWS services with Amazon Q)

## Setup Instructions

### Step 1: Create the Dockerfile

Create a new directory for your project and a Dockerfile:

```bash
mkdir -p ~/amazon_q
cd ~/amazon_q
touch Dockerfile
```

Add the following content to the Dockerfile:

```dockerfile
# Start with a Debian-based image
FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget sudo libc6 \
    libayatana-appindicator3-1 \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /app

# Download Amazon Q
RUN wget https://desktop-release.q.us-east-1.amazonaws.com/latest/amazon-q.deb

# Install Amazon Q
RUN apt-get update && \
    apt-get install -y -f && \
    dpkg -i amazon-q.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a startup script
RUN echo '#!/bin/bash\n\
if [ "$1" = "login" ]; then\n\
  q login\n\
elif [ "$1" = "chat" ]; then\n\
  q chat\n\
elif [ "$1" = "shell" ]; then\n\
  exec bash\n\
else\n\
  echo "Usage: /entrypoint.sh [login|chat|shell]"\n\
  echo "  login: Log in to Amazon Q"\n\
  echo "  chat: Start Amazon Q chat"\n\
  echo "  shell: Start a bash shell"\n\
  exit 1\n\
fi' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint to bash to keep container running
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "tail -f /dev/null"]
```

### Step 2: Build the Docker Image

Build the Docker image:

```bash
docker build -t amazon-q-cli .
```

This will create a Docker image named `amazon-q-cli` with all the necessary dependencies.

### Step 3: Create Local Directory for Credentials

Create a local directory to store Amazon Q credentials:

```bash
mkdir -p ~/.config/amazon-q
```

### Step 4: Run the Docker Container

Run the Docker container in detached mode:

```bash
docker run -d --name amazon-q -v ~/.aws:/root/.aws -v ~/.config/amazon-q:/root/.config/amazon-q amazon-q-cli
```

This command:
- Runs the container in detached mode (`-d`)
- Names the container `amazon-q` (`--name amazon-q`)
- Mounts your AWS credentials directory (`-v ~/.aws:/root/.aws`)
- Mounts a directory for Amazon Q credentials (`-v ~/.config/amazon-q:/root/.config/amazon-q`)

### Step 5: Log in to Amazon Q

Execute the login command in the container:

```bash
docker exec -it amazon-q /entrypoint.sh login
```

You'll see a prompt to select a login method. Choose "Use for Free with Builder ID" and follow the instructions to authenticate in your browser using the provided code.

### Step 6: Use Amazon Q CLI

After logging in, you can start using Amazon Q CLI:

```bash
docker exec -it amazon-q /entrypoint.sh chat
```

This will start the Amazon Q chat interface where you can interact with the AI assistant.

## Additional Commands

### Check if the container is running:
```bash
docker ps
```

### Start the container if it's stopped:
```bash
docker start amazon-q
```

### Stop the container:
```bash
docker stop amazon-q
```

### Remove the container:
```bash
docker rm amazon-q
```

### Access a shell in the container:
```bash
docker exec -it amazon-q /entrypoint.sh shell
```

## Troubleshooting

### If you encounter login issues:
Try logging out first and then logging in again:
```bash
docker exec -it amazon-q q logout
docker exec -it amazon-q /entrypoint.sh login
```

### If the container exits unexpectedly:
Check the logs to see what happened:
```bash
docker logs amazon-q
```

## Why Use Docker for Amazon Q CLI?

Using Docker for Amazon Q CLI offers several advantages:
1. **Isolation**: Keeps Amazon Q and its dependencies isolated from your system
2. **Portability**: Easily move your Amazon Q setup between different machines
3. **Consistency**: Ensures the same environment every time you run Amazon Q
4. **No System-Wide Installation**: Avoids installing dependencies system-wide
5. **Easy Updates**: Simplifies the process of updating Amazon Q

## Notes

- The container will continue running in the background until you explicitly stop it
- Your AWS credentials and Amazon Q login information are persisted through volume mounts
- This setup works specifically for the CLI version of Amazon Q
