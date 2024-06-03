#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

SYMPHONY_STATUS_FIELD="__status"
SYMPHONY_ERROR_FIELD="__error"
SUCCESS_SYMPHONY_CODE=200
ERROR_SYMPHONY_CODE=400

# Executes a command and echoes command's output. Exits on failure.
# Arguments:
#   command: The command to execute.
#   command_output: A reference to a variable that will hold the command output.
#   command_status: A reference to a variable that will hold the command status code.
function execute_command_exit_on_failure() {
    local command=$1
    local -n command_output=$2
    local -n command_status=$3

    execute_command_with_status_code "$command" command_output command_status

    if [ $command_status -ne 0 ] ; then
      echo_output_dictionary_to_output_file
      exit $command_status
    fi
}

# Executes a command and echoes command's output.
# Arguments:
#   command: The command to execute.
#   base_command_output: A reference to a variable that will hold the command output.
#   base_command_status: A reference to a variable that will hold the command status code.
function execute_command_with_status_code() {
    local command=$1
    local -n base_command_output=$2
    local -n base_command_status=$3

    # Execute the command and capture output
    base_command_output=$(eval "$command" 2>&1) || base_command_status=$?
    if [ $base_command_status -ne 0 ]; then
        echo_error_to_output_dictionary "$base_command_output"
    else
        echo_success_to_output_dictionary
    fi
}

# Inserts a success status to the output dictionary
function echo_success_to_output_dictionary() {
    echo_key_value_to_output_dictionary $SYMPHONY_STATUS_FIELD $SUCCESS_SYMPHONY_CODE
}

# Inserts an error status and message to the output dictionary
# Arguments:
#   error: The error message.
function echo_error_to_output_dictionary() {
    local error="$1"
    echo_key_value_to_output_dictionary $SYMPHONY_STATUS_FIELD $ERROR_SYMPHONY_CODE
    echo_key_value_to_output_dictionary $SYMPHONY_ERROR_FIELD "$error"
}

# Outputs our dictionary to a file.
function echo_output_dictionary_to_output_file() {
    echo "$outputs" | tee "$output_file"
}

# Inserts a key-value pair to the output dictionary
# Arguments:
#   key: The key
#   value: The value
function echo_key_value_to_output_dictionary() {
    local key=$1
    local value=$2
    outputs=$(echo "$outputs" | jq --arg key "$key" --arg value "$value" '.[$key] = $value')
}

# Gets a value from the output dictionary by passing a key
# Arguments:
#   key: The key
function get_value_from_output_dictionary() {
    local key=$1
    echo "$outputs" | jq -r --arg key "$key" '.[$key]'
}

# Script Provider Setup
# Reference: https://github.com/eclipse-symphony/symphony/blob/main/api/pkg/apis/v1alpha1/providers/stage/script/staging/test.sh
# The inputs supplied to a Symphony stage may look like the following JSON:
# {
#     "__activation": "azure_deploy_yocto_vm_activation",
#     "__activationGeneration": "1",
#     "__campaign": "azure_deploy_yocto_vm",
#     "__previousStage": "service_principal_auth",
#     "__status": 400
#     "__error": "Error: Some Error"
#     "__site": "laptop",
#     "__stage": "deploy_yocto_vm",
#     ... Additional inputs supplied to the stage.
# }
inputs_file=$1

# Store the inputs into the outputs. This allows the inputs of a stage to be used as inputs in a subsequent stage.
outputs=$(jq -c 'with_entries(.value |= "\(.)")' "$inputs_file")

# Generate the output file name
output_file="${inputs_file%.*}-output.${inputs_file##*.}"
