#!/bin/bash

# Copyright (C) Microsoft Corporation.

# This script is needed by the Target Script Provider to perform its state seeking mechanism.
# This script checks if a docker image is pulled already. If it is not pulled, the component download_software in the deployment json body will be removed. 
# This indicates to the Target Script Provider that it needs to pull the docker image in the apply_download_software.sh script.
# Nothing will occur if the image is already pulled.

# Exit immediately if a command fails.
set -e

# Fail if an unset variable is used.
set -u

deployment=$1 # first parameter file is the deployment object

#  An example of the content in the references parameter file:
# [
#   {
#     "action": "update",
#     "component": {
#       "name": "download-software",
#       "type": "download-software",
#       "properties": {
#         "source": {
#           "type": "docker",
#           "uri": "hello-world:latest"
#          },
#         "dataMounts": {
#           "pathToLocalTargetDownload": "",
#           "pathToContainerDirMount": ""
#          }
#       }
#     }
#   }
# ]

references=$2 # second parameter file contains the reference components

# To get the list of components that you need to return during this Get() call, you can
# read from the references parameter file. This file gives you a list of components and
# their associated actions, which can be either "update" or "delete". Your script is
# supposed to use this list as a reference (regardless of the action flag) to collect
# the current state of the corresponding components, and return the list. If a component
# doesn't exist, simply skip the component.

# An example of the components json after parsing the component field:

# [
#     {
#         "name": "download-software",
#         "type": "download-software",
#         "properties": {
#             "source": {
#                 "type": "docker",
#                 "uri": "hello-world:latest",
#             },
#             "dataMounts": {
#                 "path_to_local_target_download_dest": "",
#                 "pathToContainerDirMount": ""
#             }
#         }
#     }
# ]

function does_binary_exist() {

    local properties="$1"
    local components="$2"
    local component_type="$3"

    local source_type=$(echo "$properties" | jq -r '.source.commandType')
    local source_uri=$(echo "$properties" | jq -r '.source.uri')

    case "$source_type" in
    docker)
        # Check if the Docker image already exists
        if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$source_uri$"; then
            return
        fi
        ;;
    *)
        return
        ;;
    esac

    # Removing a component from the components list indicates to the Target Script Provider
    # to execute its apply script after the first dry run.
    index=$(echo "$components" | jq -r ". | index($component_type)")
    components=$(echo "$components" | jq -c "del(.[${index}])")
    echo $components
}

components=$(jq -c '.' "$references")
echo "GET REFERENCES: $components"
components=$(echo "$components" | jq -c 'map(.component)')
echo "*****GET STATUS COMPONENTS: $components****"

while IFS= read -r line; do
    component_type=$(echo "$line" | jq -r '.type')
    properties=$(echo "$line" | jq -c '.properties')

    if [ "$component_type" = "download-software" ]; then
        echo "Component type is download-software"
        components=$(does_binary_exist "$properties" "$components" "$component_type")
    fi
done <<< "$(jq -c '.[]' <<< "$components")"

# If components is empty, assign it to an empty JSON array string
if [ -z "$components" ]; then
    components="[]"
fi

# Print the new list of components
echo "*****GET STATUS COMPONENTS AFTER REMOVAL: $components****"

# Optionally, you can use the deployment parameter to get additional contextual information as needed.
# for example, you can the following query to get the instance scope.
scope=$(jq '.instance.scope' "$deployment")
echo "SCOPE: $scope"

output_components=$components
echo "$output_components" > ${deployment%.*}-output.${deployment##*.}
