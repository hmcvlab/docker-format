#!/bin/bash
set -e

# Set the project root to the top level of the git repo
project_root="$(git rev-parse --show-toplevel)"

# Run tests in a docker container
docker run \
    -t \
    --rm \
    --pull always \
    -w /workspace \
    -v "${project_root}":/workspace \
    "$(cat "${project_root}/vars/docker_image_test")" \
    /bin/bash -c "scripts/local/test.sh"
