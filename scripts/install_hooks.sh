#!/bin/bash
project_root=$(git rev-parse --show-toplevel)
ln -fvs "${project_root}/scripts/lint.sh" "${project_root}/.git/hooks/pre-commit"
ln -fvs "${project_root}/scripts/test.sh" "${project_root}/.git/hooks/pre-push"

