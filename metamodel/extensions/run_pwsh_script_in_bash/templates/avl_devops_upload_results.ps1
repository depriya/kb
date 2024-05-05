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
$UPLOAD_COMMAND_ID = "RunPowerShellScript"
$UPLOAD_SCRIPT_PATH = "$($WORKING_DIR)/upload.ps1"
$UPLOAD_SCRIPT_CONTENT = Get-Content $UPLOAD_SCRIPT_PATH -Raw 
#endregion Declare Constants

#region Getting config from metamodel config yaml
$configEncoded = "{{ parameters.input_parameter_to_script }}"
$config = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($configEncoded)) | ConvertFrom-Json
#endregion Getting config from metamodel config yaml

#region parameters - get from config
$STAGING_SA_RESOURCE_GROUP = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-$($config.project_config.environment_stage[0])-rg-001" 
$STAGING_SA_NAME = "$($config.resource_name_primary_prefix)$($config.resource_name_secondary_prefix)c$($config.project_config.oem_identifier)$($config.project_config.environment_stage[0])st" 
$CONTAINER_NAME = "$($config.project_config.project_name)".ToLower()

$localFolderPath = "$($config.reporting_stack.ResultsReturnPath)" #TODO: Check and adjust relative path where the report is generated

$VMSS_RESOURCE_GROUP = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-$($config.project_config.environment_stage[0])-rg-001" 
$VMSS_NAME = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-p-$($config.project_config.project_name)-$($config.project_config.environment_stage[0])-vmss-$($config.ade_config.vmss_suffix)"
#endregion parameters - get from config

#region Get Account key for staging storage account
Write-Host "Getting storage account key for staging storage account"
$command = @"
az storage account keys list ``
    -g $($STAGING_SA_RESOURCE_GROUP) ``
    -n $($STAGING_SA_NAME) ``
    --query "[0].value" ``
    -o tsv
"@
$storage_key = ""
$command_status = 0
Invoke-Command-ExitOnFailure -c $command -o $storage_key -s $command_status
Write-Host "Got storage account key for staging storage account."
#endregion Get Account key for staging storage account


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
  --command-id $($UPLOAD_COMMAND_ID) ``
  --scripts "$($UPLOAD_SCRIPT_CONTENT)" ``
  --parameters "StorageAccountName=$($STAGING_SA_NAME)" "ContainerName=$($CONTAINER_NAME)" "AccountKey=$($storage_key)" "localFolderPath=$($localFolderPath)"
"@
    $command_output = ""
    $command_status = 0
    Invoke-Command-ExitOnFailure -c $command -o ([ref]$command_output) -s ([ref]$command_status)
    Write-Host "Run command on VMSS instance: $($instanceId) completed."
  }
}
Write-Host "Command execution completed on all VMSS instances"
#endregion Run command for each instance in VMSS





