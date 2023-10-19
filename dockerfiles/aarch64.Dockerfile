ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Set default shell to bash
SHELL ["/bin/bash", "-c", "-o", "pipefail"]

# Set local environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set dafult command
CMD ["/bin/bash"]
