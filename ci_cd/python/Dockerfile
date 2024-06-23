FROM python:3.11-slim
RUN mkdir -p /home/ci-cd-user && addgroup ci-cd-user && useradd -d /home/ci-cd-user -g ci-cd-user ci-cd-user && chown ci-cd-user:ci-cd-user /home/ci-cd-user
RUN apt-get update && apt-get install -y curl
USER ci-cd-user
WORKDIR /home/ci-cd-user
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH=/home/ci-cd-user/.local/bin:$PATH
RUN poetry config virtualenvs.in-project true
