#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Change the current directory to the location of the script
cd "$(dirname "$0")"

# Load the variables from the config file
source create_environment.config.sh

echo "Creating environment..."
az devcenter dev environment create \
    --name $ENVIRONMENT_NAME \
    --environment-type $ENVIRONMENT_TYPE \
    --dev-center $DEV_CENTER_NAME \
    --project $DEV_CENTER_PROJECT_NAME \
    --catalog-name $DEV_CENTER_CATALOG_NAME \
    --environment-definition-name $ENVIRONMENT_DEFINITION_NAME \
    --parameters $PARAMETERS_FILE

echo "Environment creation complete!"