#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

#region get the PowerShell script details
ps_script_path=$(get_value_from_output_dictionary "ps_script_path")
arg1=$(echo $1)
#endregion get the PowerShell script details

#region Execute the PowerShell script
echo "Executing PowerShell script $ps_script_path, $arg1"

_command_output=""
_command_status=0
command="pwsh -NoProfile -File $ps_script_path -Arg $arg1"
execute_command_exit_on_failure "$command" _command_output _command_status

echo "Execution of PowerShell script $ps_script_path completed successfully."

echo_output_dictionary_to_output_file
#endregion Execute the PowerShell script
