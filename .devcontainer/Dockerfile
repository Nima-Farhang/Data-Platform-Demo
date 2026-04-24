# Dev container Dockerfile for Codespaces
# Ubuntu-based devcontainer with Node.js, AWS CLI v2, Docker CLI, Terraform

FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG TERRAFORM_VERSION=1.9.6

# Install base deps + docker cli + node/npm + unzip + gnupg + file (handy for debugging)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    unzip \
    gnupg \
    ca-certificates \
    docker.io \
    nodejs \
    npm \
    file \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 (glibc-based, works on Ubuntu)
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm -f /tmp/terraform.zip \
    && chmod +x /usr/local/bin/terraform

# Install global Node.js tooling for TypeScript dev
RUN npm install -g typescript ts-node

# Copy AWS CLI SSO configuration script (run at container start, not build)
COPY .devcontainer/aws-configure.sh /usr/local/bin/aws-configure.sh
RUN chmod +x /usr/local/bin/aws-configure.sh

# Add alias for root directory (for interactive shells)
RUN echo "alias root='cd /workspaces/WorkBench'" >> /etc/profile

# Default command: run AWS config script, then drop into bash
CMD ["/bin/bash", "-lc", "source /usr/local/bin/aws-configure.sh && exec bash"]