#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Enable tracing for debugging
set -x

# Change the current directory to the location of the script
cd "$(dirname "$0")"


#!/bin/bash

# Copyright (C) Microsoft Corporation.
customerOEMsuffix="avl" #comes from metamodel
projectname="pj" #comes from metamodel
project="xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-001"
DEV_CENTER_NAME="xmew1-dop-c-${customerOEMsuffix}-d-dc"
Pool_name="xmew1-dop-c-${customerOEMsuffix}-pools-001"
SUBID="db401b47-f622-4eb4-a99b-e0cebc0ebad4"
MYOID="70608667-2dc3-4b2a-a433-30d6ca41e377" 

echo "Installing the devcenter extension..."
az extension add --name devcenter --upgrade || handle_error "Failed to install the devcenter extension."
echo "Extension installation complete!"

 # Assign admin access
 az role assignment create --assignee $MYOID \
 --role "DevCenter Project Admin" \
 --scope "/subscriptions/$SUBID"
  # Assign admin access
 az role assignment create --assignee $MYOID \
 --role "DevCenter Dev Box User" \
 --scope "/subscriptions/$SUBID"
az devcenter dev dev-box create --pool-name $Pool_name --name "DevBoxavl" --dev-center-name $DEV_CENTER_NAME --project-name $project --user-id $MYOID
set +x