#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

az login --identity

# Write the updated key-value pairs to the output file
echo_output_dictionary_to_output_file