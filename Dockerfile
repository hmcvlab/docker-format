FROM ubuntu:24.04

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

USER root
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  perl \
  black \
  clang-format \
  python3-pytest \
  shfmt \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy custom scripts into /usr/local/bin
RUN wget --progress=dot:mega -O /usr/local/bin/latexindent \
  --no-check-certificate \
  https://github.com/cmhughes/latexindent.pl/releases/download/V3.24.7/latexindent-linux && \
  chmod +x /usr/local/bin/latexindent

# Copy configs folder into /etc
COPY configs /etc

# Entrypoint
COPY format.sh /usr/local/bin/format
RUN chmod +x /usr/local/bin/format

USER ubuntu
WORKDIR /app
ENTRYPOINT ["format"]
