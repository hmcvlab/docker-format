FROM python:3.12

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

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
  https://github.com/cmhughes/latexindent.pl/releases/download/V3.24/latexindent-linux && \
  chmod +x /usr/local/bin/latexindent

# Copy configs folder into /etc
COPY configs /etc

# Entrypoint
COPY format.sh /usr/local/bin/format
RUN chmod +x /usr/local/bin/format
WORKDIR /app
ENTRYPOINT ["format"]
