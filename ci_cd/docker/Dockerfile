FROM python:3.9-slim

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
       curl \
       unzip \
       python3-dev \
       build-essential \
       zlib1g-dev \
       libssl-dev \
       libffi-dev \
       gcc \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Verify AWS CLI installation
RUN aws --version

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python - -y \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry \
    && poetry --version

# Set PATH for Poetry
ENV PATH=/root/.local/bin:$PATH

# Clean up unnecessary packages
RUN apt-get remove -y \
    curl \
    unzip \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python environment
ENV PYTHONUNBUFFERED=1
