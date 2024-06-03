#!/bin/bash

# Copyright (C) Microsoft Corporation.

# The name of your Azure dev center.
DEV_CENTER_NAME="<DEV_CENTER_NAME>"

# The name to use for the new environment to be created.
ENVIRONMENT_NAME="<ENVIRONMENT_NAME>"

# The environment type to use for this environment.
ENVIRONMENT_TYPE="Test"

# The name of your Azure dev center project.
DEV_CENTER_PROJECT_NAME="<AZURE_DEV_CENTER_PROJECT_NAME>"

# The name of your catalog.
DEV_CENTER_CATALOG_NAME="<AZURE_DEV_CENTER_CATALOG_NAME>"

# The name of the ARM template to deploy (specified in the evironment.yaml).
ENVIRONMENT_DEFINITION_NAME="VirtualMachine"

# The name of the ARM template parameters file to use for the deployment.
PARAMETERS_FILE="existing-vnet.ARM.template.parameters.json"
