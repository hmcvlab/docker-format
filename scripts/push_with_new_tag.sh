#!/bin/bash
set -e

# Read version from vars/tag
project_root=$(git rev-parse --show-toplevel)
version=$(cat "${project_root}/vars/tag")

# Get minor version
major_version=$(echo "${version}" | cut -d . -f 1)
minor_version=$(echo "${version}" | cut -d . -f 2)
patch_version=$(echo "${version}" | cut -d . -f 3)

# Only allow 1 argument
if [[ ! "$#" -eq 1 ]]; then
  echo -e "\e[31mNot exactly 1 argument!\e[0m"
  exit 0
else
  echo "Argument: $1"
fi

# Parse flags if major, minor or patch should be increased
while [[ "$#" -gt 0 ]]; do
  case $1 in
    "--major" )
      major_version=$((major_version+1));
      minor_version=0;
      patch_version=0;
      ;;
    "--minor" )
      minor_version=$((minor_version+1));
      patch_version=0;
      ;;
    "--patch" )
      patch_version=$((patch_version+1));
      ;;
  esac
  shift
done

# If old version is equal to new version, exit
if [[ "$(cat "${project_root}/vars/tag")" == "${major_version}.${minor_version}.${patch_version}" ]]; then
  # Print the same message in red
  echo -e "\e[31mMissing argument: --major or --minor or --patch\e[0m"
  exit 0
fi

# Write new version to vars/tag
echo "${major_version}.${minor_version}.${patch_version}" > "${project_root}/vars/tag"

# Print that the version was increased
echo "Increased version from ${version} to $(cat "${project_root}/vars/tag")"

# Add the change of the version file to git
git add "${project_root}/vars/tag"
git commit --amend --no-edit

# Push the changes and the new tag
git push
git tag "$(cat "$project_root"/vars/tag)"
git push --no-verify origin "$(cat "$project_root"/vars/tag)"
