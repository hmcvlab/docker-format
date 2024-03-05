#!/bin/bash
set -e
# Run tests in a docker container
docker run \
	-t \
	--rm \
	--pull always \
	-w /workspace \
	-v "$(git rev-parse --show-toplevel)":/workspace \
	"gitlab.lrz.de:5005/messtechnik-labor/barcs/docker/continuous-integration/amd-22:latest" \
	/bin/bash -c "lint"
