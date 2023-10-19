#!/bin/bash
set -e

# Local variables
project_root="$(git rev-parse --show-toplevel)"
ci_image="gitlab.lrz.de:5005/messtechnik-labor/barcs/docker/continuous-integration/x86_64-ubuntu22:latest"

# Functions
ok() {
    printf "\e[32mok\e[0m\n"
}

lint() {
  printf "Linting %s..." "$1"
  docker run --rm -i hadolint/hadolint hadolint \
      --ignore DL3008 \
      --ignore DL3006 \
      --ignore SC1091 - < "$1"
  ok
}

docker_run(){
  printf "Running '%s'..." "$1"
  docker run -t \
    --rm \
    -v "$project_root:/project" \
    -w /project \
    "$ci_image" \
    sh -c "$1"
  ok
}

# Lint Dockerfiles
docker pull hadolint/hadolint
lint "${project_root}/dockerfiles/x86_64.Dockerfile"
lint "${project_root}/dockerfiles/aarch64.Dockerfile"

# Run shellcheck, pylint, and black in docker image
docker pull "$ci_image"
docker_run "find . -name '*.sh' | xargs shellcheck"
docker_run "black --quiet ."
docker_run "find . -name '*[a-z].py' | xargs pylint -v"
