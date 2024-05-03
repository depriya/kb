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

#region Getting config from metamodel config yaml
$configEncoded = "{{ parameters.input_parameter_to_script }}"
$config = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($configEncoded)) | ConvertFrom-Json
#endregion Getting config from metamodel config yaml

#region parameters - get from config
$ADDITIONAL_SOFTWARE_STACK = $config.additional_software_stack
$VMSS_RESOURCE_GROUP = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-$($config.project_config.environment_stage[0])-rg-001" 
$VMSS_NAME = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-p-$($config.project_config.project_name)-$($config.project_config.environment_stage[0])-vmss-$($config.ade_config.vmss_suffix)"
#endregion parameters - get from config

#region run each tool
foreach ($software in $ADDITIONAL_SOFTWARE_STACK) {
  if ( -not [string]::IsNullOrEmpty($software.BuildScriptPath)) {
    Write-Host "Running $($software.name)"

    Set-Location "C:\Temp" 
    $scriptContent = Get-Content "$($software.BuildScriptPath)" -Raw 
    $command_id = "Run$($software.BuildScriptType)Script"

    Write-Host "Get all instances of VMSS: $($VMSS_NAME) in resource group: $($VMSS_RESOURCE_GROUP)."
    $command = "az vmss list-instances --resource-group ""$($VMSS_RESOURCE_GROUP)"" --name ""$($VMSS_NAME)"" --query ""[].instanceId"" -o tsv"
    $instance_ids = ""
    $command_status = 0
    Invoke-Command-ExitOnFailure -c $command -o $instance_ids -s $command_status
    Write-Host "Got Instance IDs: $($instance_ids)."

    foreach ($instanceId in $instance_ids.Split("`t")) {
      Write-Host "Running command on instance: $($instanceId)"
      $command = "az vmss run-command invoke --resource-group ""$($VMSS_RESOURCE_GROUP)"" --name ""$($VMSS_NAME)"" --instance-id ""$($instanceId)"" --command-id ""$($command_id)"" --scripts ""$($scriptContent)"""
      $command_output = ""
      $command_status = 0
      Invoke-Command-ExitOnFailure -c $command -o $command_output -s $command_status
      Write-Host "Completed command on instance: $($instanceId)"
    }
  }
}
#endregion run each tool
