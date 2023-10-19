#!/bin/bash
set -e

# Set the project root to the top level of the git repo
project_root="$(git rev-parse --show-toplevel)"
test_docker_image="$(cat "${project_root}/vars/docker_image_test.txt")"

# Configure command
cmd="git config --global --add safe.directory /workspace"
cmd+=" && python3 -m pytest -v test/project/"
printf "Running command:\n%s\n" "${cmd}"

# Run tests in a docker container
docker run \
    -t \
    --rm \
    --pull always \
    -w /workspace  \
    -v "${project_root}":/workspace \
    "${test_docker_image}" \
    /bin/bash -c "${cmd}"
