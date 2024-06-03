#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Set working directory to current directory
working_dir="${PWD}"

# TODO: Make these configurable via the metamodel
username="toolchain"
orchestrator="eclipse-ankaios"
software_dir="/home/root/code"
repo_url="https://github.com/eclipse-sdv-blueprints/software-orchestration.git"
release_tag="main"

#The branch name you want to create
branch_name="${username}/${release_tag}"

# Use regex to match the organization and repo_name
if [[ $repo_url =~ https://github\.com/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+)\.git ]]; then
    organization="${BASH_REMATCH[1]}"
    repo_name="${BASH_REMATCH[2]}"
else
   echo "Failed to match 'https://github\.com/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+)\.git' in $repo_url"
   exit 1
fi

# Create software directory in a location that persists
mkdir -p $software_dir
cd $software_dir

# If repository does not exist, clone the repo.
if [ ! -d $repo_name ]; then
    git clone --recurse-submodules https://github.com/$organization/$repo_name.git
else
    echo "Not cloning the https://github.com/$organization/$repo_name.git because $(basename $0)/$repo_name already exists."
fi

cd $repo_name

# This creates a new local branch based on the release tag
git checkout -b $branch_name $release_tag

# Return to working dir
cd $working_dir

# Copy config files for orchestration blueprint
cp "./${orchestrator}/startupState.yaml" "${software_dir}/software-orchestration/${orchestrator}/config/startupState.yaml"
cp "./${orchestrator}/default.yaml" "${software_dir}/software-orchestration/${orchestrator}/config/default.yaml"

# Return to software directory to build blueprint image
cd $software_dir

# Build the blueprint image
docker build -t software_orchestration:0.1 --build-arg TARGETARCH=arm64 -f ./software-orchestration/${orchestrator}/.devcontainer/Dockerfile ./software-orchestration/${orchestrator}
