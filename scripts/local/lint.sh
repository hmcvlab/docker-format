#!/bin/bash
set -e

# Local variables
project_root="$(git rev-parse --show-toplevel)"

# Functions
ok() {
  printf "\e[32mok\e[0m\n"
}

lint() {
  docker run --rm -i hadolint/hadolint hadolint \
    --ignore DL3008 \
    --ignore DL3006 \
    --ignore SC1091 - <"$1"
}

header() {
  printf "\e[34mRunning '%s'...\e[0em" "$1"
}

# hadolint
header "hadolint"
docker pull hadolint/hadolint
find "$project_root" -name "*Dockerfiles" -exec lint {} \;
ok

# shellcheck
header "shellcheck"
find "$project_root" -name '*.sh' -exec shellcheck {} \;
ok

# black
header "black"
black --quiet "$project_root"
ok

# pylint
header "pylint"
find "$project_root" -name '*[a-z].py' -exec pylint --score=n {} \;
ok

# yamllint
header "yamllint"
find "$project_root" -name "*.yml" -exec yamllint {} \;
ok
