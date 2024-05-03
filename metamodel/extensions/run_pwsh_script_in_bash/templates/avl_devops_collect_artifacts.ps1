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
$STAGING_SA_RESOURCE_GROUP = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-c-$($config.project_config.oem_identifier)-$($config.project_config.environment_stage[0])-rg-001" 
$STAGING_SA_NAME = "$($config.resource_name_primary_prefix)$($config.resource_name_secondary_prefix)c$($config.project_config.oem_identifier)$($config.project_config.environment_stage[0])st" 
$STAGING_KV_NAME = "$($config.resource_name_primary_prefix)-$($config.resource_name_secondary_prefix)-s-$($config.project_config.environment_stage[0])-kv-001" 

$VERSION = "$($config.project_config.version)"
$PROJECT_NAME = "$($config.project_config.project_name)".ToLower()
$PROJECT_FOLDER_PATH = "$($config.project_config.project_name)_$($config.project_config.version)"

$MODEL_STACK = $config.model_stack.ModulesLibrary 
$ADDITIONAL_SOFTWARE_STACK = $config.additional_software_stack
$REPORTING_STACK = $config.reporting_stack.TestReportTemplateLibrary
#endregion parameters - get from config

#region Create project folder
if (Test-Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)") {
    Write-Host "Removing existing project folder $($PROJECT_FOLDER_PATH)"
    Remove-Item -Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)" -Force
    Write-Host "Removed existing project folder $($PROJECT_FOLDER_PATH)"
}

if (Test-Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging") {
    Write-Host "Removing existing project folder $($PROJECT_FOLDER_PATH)_Staging"
    Remove-Item -Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging" -Force
    Write-Host "Removed existing project folder $($PROJECT_FOLDER_PATH)_Staging"
}

New-Item -Path "$($WORKING_DIR)" -Name "$($PROJECT_FOLDER_PATH)_Staging" -ItemType "directory" -Force
New-Item -Path "$($WORKING_DIR)" -Name "$($PROJECT_FOLDER_PATH)" -ItemType "directory" -Force
Set-Location "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging"

#endregion Create project folder

#region Collect model stack files
Write-Host "Collecting model stack files"
$MODEL_STACK_LIBS = $MODEL_STACK | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
foreach ($library in $MODEL_STACK_LIBS) {
    foreach ($module in $MODEL_STACK."$($library)") {
        if ($module | Get-Member -Name DownloadSource -MemberType Properties) {
            if ($module.DownloadSource.Type -eq "GitHub") {
                $github_pat_token = $(az keyvault secret show --vault-name $STAGING_KV_NAME --name $($module.DownloadSource.Secret) --query value -o tsv)
                $LocationURL = $module.DownloadSource.LocationURL
                $repo_name = $LocationUrl -replace '\.git$', '' -split '/' | Select-Object -Last 1
                if (-not (Test-Path -LiteralPath $repo_name)) {
                    Write-Host "Cloning $LocationURL"
                    git clone $LocationUrl.Replace('github.com', "$($github_pat_token)@github.com")
                    Write-Host "Cloning $LocationURL completed"
                }
                if ($module | Get-Member -Name SubSys -MemberType Properties) {
                    foreach ($subSys in $module.SubSys) {
                        if ( -not [string]::IsNullOrWhiteSpace($subSys.ModuleFilePath)) {
                            Write-Host "Copying from ModuleFilePath - $($subSys.ModuleFilePath)"
                            Copy-Item "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging/$($subSys.ModuleFilePath)" "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)/$($subSys.ModuleFilePath)" -Force
                            Write-Host "Copying from ModuleFilePath - $($subSys.ModuleFilePath) completed"
                        }
                        if ($subSys | Get-Member -Name SubSysParam -MemberType Properties) {
                            foreach ($subSysParam in $subSys.SubSysParam) {
                                if (-not [string]::IsNullOrWhiteSpace($subSysParam.ParamFilePath)) {
                                    Write-Host "Copying from ParamFilePath - $($subSysParam.ParamFilePath)"
                                    Copy-Item "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging/$($subSysParam.ParamFilePath)" "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)/$($subSysParam.ParamFilePath)" -Force
                                    Write-Host "Copying from ParamFilePath - $($subSysParam.ParamFilePath)"
                                }
                            }
                        }
                    }
                }
            }       
        }
    }
}
Write-Host "Completed collection of model stack files"
#endregion Collect model stack files

#region Collect additional software stack files
Write-Host "Collecting additional software stack files"
foreach ($software in $ADDITIONAL_SOFTWARE_STACK) {
    if ($software.DownloadSource.Type -eq "GitHub") {
        $github_pat_token = $(az keyvault secret show --vault-name $STAGING_KV_NAME --name $($software.DownloadSource.Secret) --query value -o tsv)
        $LocationURL = $software.DownloadSource.LocationURL
        $repo_name = $LocationUrl -replace '\.git$', '' -split '/' | Select-Object -Last 1
        if (-not (Test-Path -LiteralPath $repo_name)) {
            Write-Host "Cloning $LocationURL"
            git clone $LocationUrl.Replace('github.com', "$($github_pat_token)@github.com")
            Write-Host "Cloning $LocationURL completed"
        }
        Write-Host "Copying from FilePath - $($software.FilePath)"
        Copy-Item "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging/$($software.FilePath)" "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)/$($software.FilePath)" -Force
        Write-Host "Copying from FilePath - $($software.FilePath) completed"

        if (-not [string]::IsNullOrWhiteSpace($software.BuildScriptPath)) {
            Write-Host "Copying from BuildScriptPath - $($software.BuildScriptPath)"
            Copy-Item "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging/$($software.BuildScriptPath)" "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)/$($software.BuildScriptPath)" -Force
            Write-Host "Copying from BuildScriptPath - $($software.BuildScriptPath) completed"
        }
    }
}
Write-Host "Completed collection of additional software stack files"
#endregion Collect additional software stack files

#region Collect additional software stack files
Write-Host "Collecting reporting stack files"
foreach ($item in $REPORTING_STACK) {
    if ($item.DownloadSource.Type -eq "GitHub") {
        $github_pat_token = $(az keyvault secret show --vault-name $STAGING_KV_NAME --name $($item.DownloadSource.Secret) --query value -o tsv)
        $LocationURL = $item.DownloadSource.LocationURL
        $repo_name = $LocationUrl -replace '\.git$', '' -split '/' | Select-Object -Last 1
        if (-not (Test-Path -LiteralPath $repo_name)) {
            Write-Host "Cloning $LocationURL"
            git clone $LocationUrl.Replace('github.com', "$($github_pat_token)@github.com")
            Write-Host "Cloning $LocationURL completed"
        }
        if ($item | Get-Member -Name SubSys -MemberType Properties) {
            foreach ($subSys in $item.SubSys) {
                if ( -not [string]::IsNullOrWhiteSpace($subSys.ModuleFilePath)) {
                    Write-Host "Copying from ModuleFilePath - $($subSys.ModuleFilePath)"
                    Copy-Item "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging/$($subSys.ModuleFilePath)" "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)/$($subSys.ModuleFilePath)" -Force
                    Write-Host "Copying from ModuleFilePath - $($subSys.ModuleFilePath) completed"
                }
                if ($subSys | Get-Member -Name SubSysParam -MemberType Properties) {
                    foreach ($subSysParam in $subSys.SubSysParam) {
                        if (-not [string]::IsNullOrWhiteSpace($subSysParam.ParamFilePath)) {
                            Write-Host "Copying from ParamFilePath - $($subSysParam.ParamFilePath)"
                            Copy-Item "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging/$($subSysParam.ParamFilePath)" "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)/$($subSysParam.ParamFilePath)" -Force
                            Write-Host "Copying from ParamFilePath - $($subSysParam.ParamFilePath)"
                        }
                    }
                }
            }
        }
    }
}
Write-Host "Completed collection of reporting stack files"
#endregion Collect additional software stack files

#region Compress project folder
Write-Host "Compressing project folder"
Set-Location "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)"
Compress-Archive -Path . -DestinationPath "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH).zip" -Force
Write-Host "Completed compressing project folder"
#endregion Compress project folder

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
Invoke-Command-ExitOnFailure -c $command -o ([ref]$storage_key) -s ([ref]$command_status)
Write-Host "Got storage account key for staging storage account."
#endregion Get Account key for staging storage account

#region Creating container in staging storage account and
Write-Host "Creating container in staging storage account"
$command = @"
az storage container create ``
    --account-name $($STAGING_SA_NAME) ``
    --account-key "$($storage_key)" ``
    -n $($PROJECT_NAME) ``
    --only-show-errors
"@
$command_output = ""
$command_status = 0
Invoke-Command-ExitOnFailure -c $command -o ([ref]$command_output) -s ([ref]$command_status)
Write-Host "Completed creating container in staging storage account."
#endregion Creating container in staging storage account

#region Upload to staging storage account
Write-Host "Uploading to compressed zip to staging storage account"
$command = @"
az storage blob upload ``
    --account-name $($STAGING_SA_NAME) ``
    --account-key "$($storage_key)" ``
    -c $($PROJECT_NAME) ``
    -n "$($VERSION).zip" ``
    -f "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH).zip" ``
    --overwrite ``
    --only-show-errors
"@
$command_output = ""
$command_status = 0
Invoke-Command-ExitOnFailure -c $command -o ([ref]$command_output) -s ([ref]$command_status)
Write-Host "Completed upload to staging storage account."
#endregion Upload to staging storage account

# if (Test-Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging") {
#     Write-Host "Removing existing project folder $($PROJECT_FOLDER_PATH)_Staging"
#     Remove-Item -Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)_Staging" -Recurse -Force
#     Write-Host "Removed existing project folder $($PROJECT_FOLDER_PATH)_Staging"
# }

# if (Test-Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)") {
#     Write-Host "Removing existing project folder $($PROJECT_FOLDER_PATH)"
#     Remove-Item -Path "$($WORKING_DIR)/$($PROJECT_FOLDER_PATH)" -Recurse -Force
#     Write-Host "Removed existing project folder $($PROJECT_FOLDER_PATH)"
# }

Write-OutputDictionaryToOutputFile
exit 0