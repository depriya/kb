#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Enable tracing for debugging
set -x

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Change the current directory to the location of the script
cd "$(dirname "$0")"

# Load the variables from the config file
source create_environment.config.sh

# Function to handle errors
handle_error() {
    log_message "ERROR: $1"
    exit 1
}

log_message "Starting environment creation process..."

log_message "Installing the devcenter extension..."
az extension add --name devcenter || handle_error "Failed to install the devcenter extension."

log_message "Extension installation complete!"

log_message "Assigning Contributor role to DevCenter identity..."
az role assignment create --assignee eb47c23a-720a-4576-b494-5491e1f134ca --role owner --scope /subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4 || handle_error "Failed to assign Contributor role to DevCenter identity."

log_message "Role assignment complete!"

log_message "Creating environment..."
az devcenter dev environment create \
    --name $ENVIRONMENT_NAME \
    --environment-type $ENVIRONMENT_TYPE \
    --dev-center $DEV_CENTER_NAME \
    --project $DEV_CENTER_PROJECT_NAME \
    --catalog-name $DEV_CENTER_CATALOG_NAME \
    --environment-definition-name $ENVIRONMENT_DEFINITION_NAME \
    --parameters '{"resource_name":"xmew1-dop-c-oem-rrr-vmss-001","OEM":"rrr","admin_username":"dkpriya","admin_password":"Azure@123456"}' \
    --debug
    #--parameters $PARAMETERS_FILE || handle_error "Failed to create environment."

log_message "Environment creation complete!"

# Disable tracing
set +x
