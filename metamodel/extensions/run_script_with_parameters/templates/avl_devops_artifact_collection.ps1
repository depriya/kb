#!/usr/bin/env pwsh

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Fail if an unset variable is used
Set-StrictMode -Version Latest

. ./symphony_stage_script_provider.ps1

#region Getting config from metamodel config yaml
$configEncoded = "{{ parameters.input_parameter_to_script }}"
$github_pat_token = "<<github_pat_token>>"
$config = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($configEncoded)) | ConvertFrom-Json
#endregion Getting config from metamodel config yaml

#region initialize variables
$DOWNLOAD_REQUEST_TIMEOUT_SECONDS = 600
$DOWNLOAD_REQUEST_MAX_REDIRECT = 5
$DOWNLOAD_REQUEST_MAX_RETRY = 5

$STAGING_SA_SUBSCRIPTION_ID = "$($config.staging_storage_account.subscription_id)"
$STAGING_SA_RESOURCE_GROUP = "$($config.staging_storage_account.resource_group)"
$STAGING_SA_NAME = "$($config.staging_storage_account.name)"
$JFROG_DOWNLOAD_URL = "$($config.jfrog.download_url)"
$JFROG_EDGE_TOKEN = "<<jfrog_token>>"

$VERSION = "$($config.version)"
$MODEL_STACK = $config.model_stack
$REPOS_TO_CLONE = $config.clone_github_repositories

$ProjectFolderPath = "$($config.project_name)_$($config.version)"
#endregion initialize variables

#region clone github repositories using pat token
foreach ($repo in $REPOS_TO_CLONE) {
    $repoCloneUrl = "https://$($github_pat_token)@github.com/$($repo.organisation)/$($repo.repository).git"
    $command = "git clone ""$($repoCloneUrl)"" --depth 1 --no-tags"
    $command_output = $null
    $command_status = 0
    Invoke-CommandWithStatusCode -c $command -o $command_output -s $command_status
    if ($command_status -ne 0) {
        Write-OutputDictionaryToOutputFile
    }
}
#endregion clone github repositories using pat token

#region download jfrog artifact
New-Item -Path $PWD -Name $ProjectFolderPath -ItemType Directory -Force
Set-Location "$PWD/$ProjectFolderPath"
$headers = @{ "Authorization" = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($JFROG_EDGE_TOKEN)")))" }

$command = @"
Invoke-WebRequest `
    -Method GET `
    -Uri $($JFROG_DOWNLOAD_URL) `
    -Headers $($headers)`
    -ConnectionTimeoutSeconds $($DOWNLOAD_REQUEST_TIMEOUT_SECONDS) `
    -PreserveAuthorizationOnRedirect `
    -MaximumRedirection $($DOWNLOAD_REQUEST_MAX_REDIRECT) `
    -MaximumRetryCount $($DOWNLOAD_REQUEST_MAX_RETRY) `
    -PassThru `
    -OutFile
"@
$command_output = $null
$command_status = 0
Invoke-CommandWithStatusCode -c $command -o $command_output -s $command_status
if ($command_status -ne 0) {
    Write-OutputDictionaryToOutputFile
}
#endregion download jfrog artifact

#region collect model stack files
$MODEL_STACK_PROPERTIES = $MODEL_STACK | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
$ARRAY_TO_PROCESS = @()
foreach ($property in $MODEL_STACK_PROPERTIES) {
    Write-Host "Processing property: $property, found type: $($MODEL_STACK.$property.GetType().BaseType.Name)"
    if ($MODEL_STACK.$property.GetType().BaseType.Name -eq "Object") {
        $nestedModuleProperties = $MODEL_STACK.$property | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
        foreach ($nestedModuleProperty in $nestedModuleProperties) {
            Write-Host "Processing nested property: $nestedModuleProperty, found type: $($MODEL_STACK.$property.$nestedModuleProperty.GetType().BaseType.Name)"
            if ($MODEL_STACK.$property.$nestedModuleProperty.GetType().BaseType.Name -eq "Array") {
                Write-Host "Adding to array to process: $($MODEL_STACK.$property.$nestedModuleProperty)"
                $ARRAY_TO_PROCESS += $MODEL_STACK.$property.$nestedModuleProperty
            }
        }
    }
    elseif ($MODEL_STACK.$property.GetType().BaseType.Name -eq "Array") {
        Write-Host "Adding to array to process: $property"
        $ARRAY_TO_PROCESS += $MODEL_STACK.$property
    }
}
foreach ($item in $ARRAY_TO_PROCESS) {
    if ($item.GetType().BaseType.Name -eq "Object" ) {
        if ($item.PSObject.Properties.Name -contains "SubSys" -and $item.SubSys.GetType().BaseType.Name -eq "Array") {
            foreach ($subSys in $item.SubSys) {
                if ($subSys.GetType().BaseType.Name -eq "Object" -and $subSys.PSObject.Properties.Name -contains "ModuleFilePath" -and $null -ne $subSys.ModuleFilePath) {
                    Write-Host "Copying from ModuleFilePath - $PWD/$($subSys.ModuleFilePath)"
                    Copy-Item "$PWD/$($subSys.ModuleFilePath)" "$PWD" -Recurse -Force
                    if ($subSys.PSObject.Properties.Name -contains "SubSysParam" -and $subSys.SubSysParam.GetType().BaseType.Name -eq "Array") {
                        foreach ($subSysParam in $subSys.SubSysParam) {
                            if ($subSysParam.GetType().BaseType.Name -eq "Object" -and $subSysParam.PSObject.Properties.Name -contains "ParamFilePath" -and $null -ne $subSysParam.ParamFilePath) {
                                Write-Host "Copying from ParamFilePath - $PWD/$($subSysParam.ParamFilePath)"
                                Copy-Item "$PWD/$($subSysParam.ParamFilePath)" "$PWD" -Recurse -Force
                            }
                        }
                    }
                }
            }
        }
    }
}
#endregion collect model stack files

#region compress project folder
Compress-Archive "$PWD" "$PWD.zip" -Force
#endregion compress project folder

#region upload to staging storage account
$storage_key =
az storage account keys list `
    -s $STAGING_SA_SUBSCRIPTION_ID `
    -g $STAGING_SA_RESOURCE_GROUP `
    -n $STAGING_SA_NAME `
    --query "[0].value" `
    -o tsv

$command = @"
az storage container create `
    --account-name $($STAGING_SA_NAME) `
    --account-key "$($storage_key)" `
    -n $($ProjectFolderPath) `
    --only-show-errors
"@
$command_output = $null
$command_status = 0
Invoke-CommandWithStatusCode -c $command -o $command_output -s $command_status
if ($command_status -ne 0) {
    Write-OutputDictionaryToOutputFile
}

$command = @"
az storage blob upload `
    --account-name $($STAGING_SA_NAME) `
    --account-key "$($storage_key)" `
    -c $($ProjectFolderPath) `
    -n $($VERSION) `
    -f "$($PWD).zip" `
    --overwrite `
    --only-show-errors
"@
$command_output = $null
$command_status = 0
Invoke-CommandWithStatusCode -c $command -o $command_output -s $command_status
#endregion upload to staging storage account

Write-OutputDictionaryToOutputFile
