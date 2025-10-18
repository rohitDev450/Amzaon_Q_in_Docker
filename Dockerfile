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
