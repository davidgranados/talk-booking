FROM docker:24.0

# Install glibc compatibility for Alpine
ENV GLIBC_VER=2.34-r0
RUN apk --no-cache add binutils curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --force-overwrite --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk \
    && rm glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk \
    && apk del binutils

# Install AWS CLI v2
RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws /var/cache/apk/* /root/.cache

# Verify AWS CLI installation
RUN /usr/local/bin/aws --version

# Set Python environment
ENV PYTHONUNBUFFERED=1

# Install Python and dependencies
RUN apk add --update --no-cache python3 build-base zlib-dev openssl-dev libffi-dev python3-dev \
    && ln -sf python3 /usr/bin/python

# Install Poetry
RUN apk add --update --no-cache curl \
    && curl -sSL https://install.python-poetry.org | python - -y \
    && apk del curl \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry \
    && poetry --version

# Set PATH for Poetry
ENV PATH=/root/.local/bin:$PATH
