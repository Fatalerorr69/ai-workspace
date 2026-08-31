FROM mcr.microsoft.com/devcontainers/universal:2

# Instalace dalších nástrojů
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*
