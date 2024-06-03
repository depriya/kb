#!/bin/bash

# Copyright (C) Microsoft Corporation.

# This script is needed by the Target Script Provider to perform its state seeking mechanism.
# This script is activated by the Target Script Provider if the component download_software in the deployment json body is removed. 

# Exit immediately if a command fails.
set -e

# Fail if an unset variable is used.
set -u

# References:
# https://github.com/eclipse-symphony/symphony/blob/main/coa/pkg/apis/v1alpha2/types.go
# https://github.com/eclipse-symphony/symphony/blob/main/api/pkg/apis/v1alpha1/providers/target/script/mock-apply.sh
# 8001: failed to update.
# 8004: updated (success).
# 9998: untouched - no actions are taken/necessary.
ERROR_SYMPHONY_AGENT_CODE=8001
SUCCESS_SYMPHONY_AGENT_CODE=8004
UNTOUCHED_SYMPHONY_AGENT_CODE=9998

deployment=$1 # first parameter file is the deployment object

# See the example below for the content in the references parameter file:
references=$2 # second parmeter file contains the reference components

# An example of the components json:
# [
#       "name": "download-software",
#       "type": "download-software",
#       "properties": {
#         "source": {
#           "type": "docker",
#           "uri": "hello-world:latest",
#          },
#         "dataMounts": {
#           "pathToLocalTargetDownload": "",
#           "pathToContainerDirMount": ""
#          }
# ]

# This apply script is called with a list of components
# to be updated through the references parameter.
# On the first run of starting up the Symphony agent, the components
# list contains the all the components; therefore, each component will be updated.
# If a component is not included in the list, then the
# target script provider will not execute the script for that component.
components=$(jq -c '.' "$references")
echo "*****APPLY COMPONENTS: $components****"
output_results="{}"

function download_binary() {
    local properties="$1"
    local output_results="{}"

    local source_type=$(echo "$properties" | jq -r '.source.type')
    local source_uri=$(echo "$properties" | jq -r '.source.uri')

    case "$source_type" in
    docker)

        # Checking for image is newly pulled or already pulled
        # Docker pull returns a status output.
        docker_output=$(docker pull $source_uri 2>&1) || docker_output_status=$?

        if echo "$docker_output" | grep -q -e "Status: Downloaded newer image" -e "Status: Image is up to date"; then
            message="Docker pull success for image $source_uri."
            output_results=$(echo $output_results | jq --arg key "$component_type" --arg msg "$message" --argjson status "$SUCCESS_SYMPHONY_AGENT_CODE" '. | .[$key] = {"status": $status, "message": $msg}')
        else
            message="Docker pull failed due to $docker_output. ERROR CODE $docker_output_status"
            output_results=$(echo $output_results | jq --arg key "$component_type" --arg msg "$message" --argjson status "$ERROR_SYMPHONY_AGENT_CODE" '. | .[$key] = {"status": $status, "message": $msg}')
        fi
        ;;
    *)
        message="The command type $source_type is not supported."
        output_results=$(echo $output_results | jq --arg key "$component_type" --arg msg "$message" --argjson status "$UNTOUCHED_SYMPHONY_AGENT_CODE" '. | .[$key] = {"status": $status, "message": $msg}')
        return
        ;;
    esac

    echo $output_results
}

while IFS= read -r line; do
    component_type=$(echo "$line" | jq -r '.type')
    properties=$(echo "$line" | jq -c '.properties')

    if [ "$component_type" = "download-software" ]; then
        echo "Component type is download-software"
        output_results=$(download_binary "$properties" "$components")
    else
        echo "Unknown component $component_type"
    fi
done <<< "$(jq -c '.[]' <<< "$components")"

# Optionally, you can use the deployment parameter to get additional contextual information as needed.
# for example, you can the following query to get the instance scope.

scope=$(jq '.instance.scope' "$deployment")
echo "SCOPE: $scope"

# Example of output_results:
# {
#     "COMPONENT_1_TYPE": {
#         "status": 8004,
#         "message": "Update: success"
#     },
#     "COMPONENT_2_TYPE": {
#         "status": 8001,
#         "message": "Update: error"
#     }
# }
echo "APPLY RESULTS: $output_results"
echo "$output_results" > ${deployment%.*}-output.${deployment##*.}
