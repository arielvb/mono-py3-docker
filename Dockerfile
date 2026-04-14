# Builder stage for .NET tools
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim AS dotnet-builder
RUN dotnet tool install -g csharpier --version 1.2.6

# Final stage
FROM python:3.12-slim-bookworm

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="1" \
    DOTNET_CLI_TELEMETRY_OPTOUT="true" \
    DEBIAN_FRONTEND="noninteractive" \
    PATH="/root/.dotnet/tools:${PATH}"

# Install runtime dependencies, .NET runtime, and python packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    && curl -sSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends \
    dotnet-sdk-8.0 \
    && pip install --no-cache-dir lxml pre-commit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Copy installed dotnet tools from builder
COPY --from=dotnet-builder /root/.dotnet/tools /root/.dotnet/tools
