#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

# Run Cognata requirements
pyScriptRequirements="pip3 install --user -r $(dirname $0)/requirements.txt"
pyScriptRequirements_output=""
pyScriptRequirements_status=0
execute_command_with_status_code "$pyScriptRequirements" pyScriptRequirements_output pyScriptRequirements_status

# Write the updated key-value pairs to the output file
echo_output_dictionary_to_output_file
