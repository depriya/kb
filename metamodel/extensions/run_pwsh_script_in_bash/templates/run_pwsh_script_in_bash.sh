#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

#region get the PowerShell script details
ps_script_path=$(get_value_from_output_dictionary "ps_script_path")
#endregion get the PowerShell script details

#region Execute the PowerShell script
echo "Executing PowerShell script $ps_script_path"
pwsh -f "$ps_script_path" "$(dirname "$0")" "$1"
echo "Execution of PowerShell script $ps_script_path completed successfully."
#endregion Execute the PowerShell script
