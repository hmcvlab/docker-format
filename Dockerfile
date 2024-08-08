FROM ros:humble

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  python3-numpy \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

