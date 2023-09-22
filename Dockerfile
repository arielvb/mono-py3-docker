FROM python:3.9.17-slim-buster
# https://github.com/docker-library/python/blob/40bd50cfcf3551fc506b45e47003db9c52c5fec7/3.9/slim-buster/Dockerfile

ENV MONO_VERSION 6.12.0.182

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="1"

# Disable dotnet telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT="true"
# Configure env for csharpier
ENV PATH="/root/.dotnet/tools:${PATH}"
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update \
  && apt-get install -y --no-install-recommends gnupg dirmngr ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && gpg --batch --export --armor 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF > /etc/apt/trusted.gpg.d/mono.gpg.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && apt-key list | grep Xamarin \
  && apt-get purge -y --auto-remove gnupg dirmngr

# Install mono-runtime, monodevelop, nuget and msbuild and extra tools curl and git
RUN echo "deb https://download.mono-project.com/repo/debian buster/snapshots/$MONO_VERSION main" > /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get update \
  && apt-get install -y mono-runtime msbuild nuget monodevelop curl git

# Install dotnet and csharpier
RUN curl -O https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && apt-get install -y apt-utils apt-transport-https && apt-get update && \
    apt-get install dotnet-sdk-6.0 -y && dotnet tool install -g csharpier --version 0.16 \
    && apt-get purge -y --auto-remove apt-utils apt-transport-https \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN pip install --no-cache lxml pre-commit
