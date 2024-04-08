#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Change the current directory to the location of the script
cd "$(dirname "$0")"

# Load the variables from the config file
source setup_catalog.config.sh

# Constants
CATALOG_SETUP_TEMPLATE_FILE="Catalog.Setup.ARM.template.json"
CATALOG_SETUP_TEMPLATE_PARAMETERS_FILE="Catalog.Setup.ARM.template.parameters.json"

echo "Deploying ARM template for catalog setup..."
az deployment group create \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file $CATALOG_SETUP_TEMPLATE_FILE \
    --parameters $CATALOG_SETUP_TEMPLATE_PARAMETERS_FILE

echo "Catalog setup complete!"
