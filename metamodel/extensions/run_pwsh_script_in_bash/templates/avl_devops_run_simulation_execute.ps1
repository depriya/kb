#!/usr/bin/env pwsh

# Copyright (C) Microsoft Corporation.

param(
  [Parameter(Mandatory = $true)][string] $Arg
)

# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Fail if an unset variable is used
Set-StrictMode -Version Latest

. $PSScriptRoot/symphony_stage_script_provider.ps1 "$($Arg)"

$WORKING_DIR = Split-Path -Path "$($Arg)" -Parent

#region Declare Constants
$EXECUTE_COMMAND_ID = "RunPowerShellScript" #TODO: Check and adjust the command id
$EXECUTE_SCRIPT_PATH = "$($WORKING_DIR)/execute_model_connect_project.bat"
$EXECUTE_SCRIPT_CONTENT = Get-Content $EXECUTE_SCRIPT_PATH -Raw 
#endregion Declare Constants

#region Getting config from metamodel config yaml
$configEncoded = "{{ parameters.input_parameter_to_script }}"
$config = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($configEncoded)) | ConvertFrom-Json
#endregion Getting config from metamodel config yaml

#region parameters - get from config
$VMSS_RESOURCE_GROUP = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-$($config.project_config.environment_stage[0])-rg-001" 
$VMSS_NAME = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-p-$($config.project_config.project_name)-$($config.project_config.environment_stage[0])-vmss-$($config.ade_config.vmss_suffix)"
#endregion parameters - get from config

#region Get all instances for the VMSS 
Write-Host "Get all instances of VMSS: $($VMSS_NAME) in resource group: $($VMSS_RESOURCE_GROUP)."
$command = "az vmss list-instances --resource-group ""$($VMSS_RESOURCE_GROUP)"" --name ""$($VMSS_NAME)"" --query ""[].instanceId"" -o tsv"
$instance_ids = ""
$command_status = 0
Invoke-Command-ExitOnFailure -c $command -o ([ref]$instance_ids) -s ([ref]$command_status)
Write-Host "Got Instance IDs: $($instance_ids)."
#endregion Get all instances for the VMSS

#region Run command for each instance in VMSS
Write-Host "Running command on all VMSS instances"
foreach ($instanceId in $instance_ids.Split("`t")) {
  if (-not [string]::IsNullOrWhiteSpace($instanceId)) {
    Write-Host "Running command on VMSS instance: $($instanceId)"
    $command = @"
az vmss run-command invoke ``
  --resource-group $($VMSS_RESOURCE_GROUP) ``
  --name $($VMSS_NAME) ``
  --instance-id $($instanceId) ``
  --command-id $($EXECUTE_COMMAND_ID) ``
  --scripts "$($EXECUTE_SCRIPT_CONTENT)" 
"@
    $command_output = ""
    $command_status = 0
    Invoke-Command-ExitOnFailure -c $command -o ([ref]$command_output) -s ([ref]$command_status)
    Write-Host "Run command on VMSS instance: $($instanceId) completed."
  }
}
Write-Host "Command execution completed on all VMSS instances"
#endregion Run command for each instance in VMSS





