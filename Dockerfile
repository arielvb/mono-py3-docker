FROM python:3.10-slim-bookworm
# https://github.com/docker-library/python/blob/40bd50cfcf3551fc506b45e47003db9c52c5fec7/3.9/slim-buster/Dockerfile

ENV MONO_VERSION 6.12.0.182

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="1"

# Disable dotnet telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT="true"
# Configure env for csharpier
ENV PATH="/root/.dotnet/tools:${PATH}"
ENV DEBIAN_FRONTEND="noninteractive"


# Install mono-runtime, monodevelop, nuget and msbuild and extra tools curl and git
RUN apt-get update \
  && apt-get install -y curl git && \
  curl -O https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && apt-get install -y apt-utils apt-transport-https && apt-get update && \
    apt-get install dotnet-sdk-8.0 dotnet-sdk-7.0 dotnet-runtime-8.0 -y && dotnet tool install -g csharpier --version 0.25 \
    && apt-get purge -y --auto-remove apt-utils apt-transport-https \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN pip install --no-cache lxml pre-commit
