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
  if ($software | Get-Member -Name BuildScriptPath -MemberType Properties) {
    if ( -not [string]::IsNullOrWhiteSpace($software.BuildScriptPath)) {
      Write-Host "Running $($software.name)"

      Set-Location "C:\Temp\" 
      $scriptContent = Get-Content "$($software.BuildScriptPath)" -Raw 
      $command_id = "Run$($software.BuildScriptType)Script"

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
          $command = "az vmss run-command invoke --resource-group ""$($VMSS_RESOURCE_GROUP)"" --name ""$($VMSS_NAME)"" --instance-id ""$($instanceId)"" --command-id ""$($command_id)"" --scripts $($scriptContent)"
          $command_output = ""
          $command_status = 0
          Invoke-Command-ExitOnFailure -c $command -o ([ref]$command_output) -s ([ref]$command_status)
          Write-Host "Completed command on instance: $($instanceId)"
        }
      }
      Write-Host "Command execution completed on all VMSS instances"
      #endregion Run command for each instance in VMSS
    }
  }
}
#endregion run each tool
