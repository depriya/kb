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

echo "Assigning role to DevCenter identity..."
az role assignment create --assignee eb47c23a-720a-4576-b494-5491e1f134ca --role Contributor --scope /subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4

echo "Role assignment complete!"

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
