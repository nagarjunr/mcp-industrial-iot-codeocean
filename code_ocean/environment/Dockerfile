# Code Ocean environment for iot-mcp-servers reproducibility capsule.
#
# Base: Python 3.12 with uv (the dependency/runner tool every server in this repo
# uses).
#
# Known constraint (documented honestly, not hidden): a Code Ocean Reproducible Run
# environment is itself a Docker container, so running a NESTED docker-compose stack
# for the 3 servers that need one (eclipse-ditto, mqtt, sparkplug-b) requires
# Docker-in-Docker support, which standard (non-privileged) Code Ocean compute plans
# do not provide. An earlier version of this Dockerfile tried installing the Docker
# CLI via Docker's official apt repo, hardcoded to the Debian codename/URL -- but
# Code Ocean's actual build environment reports an Ubuntu codename (jammy) at that
# layer, not Debian, causing a 404 (the Debian repo has no "jammy" release). Rather
# than chase distro-detection edge cases for a capability (nested Docker) that's
# speculative on Code Ocean's standard plans anyway, this Dockerfile does not attempt
# to install a Docker client at all.
#
# code_ocean/run already checks `command -v docker` before attempting anything
# docker-compose-related, and degrades gracefully (with a clearly logged reason) if
# no docker binary is present -- so this simplification does not silently break
# anything; it just means the 3 docker-compose-dependent servers will reliably report
# a graceful skip here, while the 2 fully self-contained servers (aws-iot-core: tests
# `moto` directly; azure-iot-hub: tests `respx` + a local AMQP fake directly, neither
# needs docker) always run and pass regardless.
#
# If you later confirm your specific Code Ocean plan does support privileged/DinD
# execution and want to actually run the 3 docker-compose servers inside a capsule,
# add a Docker CLI install step back in, but detect the ACTUAL base OS ID (not just
# assume Debian) via `. /etc/os-release && echo "$ID"` and pick the matching
# https://download.docker.com/linux/<ID> repository (debian vs ubuntu) accordingly.

FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# uv: this project's actual dependency/runner tool (see each server's pyproject.toml)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /code
