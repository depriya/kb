#!/usr/bin/env pwsh

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Fail if an unset variable is used
Set-StrictMode -Version Latest

#region Define constants
$SYMPHONY_STATUS_FIELD = "__status"
$SYMPHONY_ERROR_FIELD = "__error"
$SUCCESS_SYMPHONY_CODE = 200
$ERROR_SYMPHONY_CODE = 400
#endregion Define constants

#region Define functions
function Get-ValueFromOutputDictionary {
    <#
    .SYNOPSIS
    Retrieves a value from the output dictionary.
    .DESCRIPTION
    Retrieves a value corresponding to the input key from the $outputs dictionary, initialized in the execution scope.
    .PARAMETER Key
    The input key to retrieve from the $outputs dictionary.
    .EXAMPLE
    Get-ValueFromOutputDictionary -Key "my_key"
    .EXAMPLE
    Get-ValueFromOutputDictionary -k "my_key"
    .EXAMPLE
    Get-ValueFromOutputDictionary "my_key"
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias("k", "Key")]
        [string]$key
    )

    return $outputs[$key]
}

function Add-KeyValuePairToOutputDictionary {
    <#
    .SYNOPSIS
    Adds a key-value pair to the output dictionary.
    .DESCRIPTION
    Adds the input key-value pair to the $outputs dictionary, initialized in the execution scope.
    .PARAMETER Key
    The input key to add to the $outputs dictionary, initialized in the execution scope.
    .PARAMETER Value
    The input value to add to the $outputs dictionary, initialized in the execution scope.
    .EXAMPLE
    Add-KeyValuePairToOutputDictionary -Key "my_key" -Value "my_value"
    .EXAMPLE
    Add-KeyValuePairToOutputDictionary -k "my_key" -v "my_value"
    .EXAMPLE
    Add-KeyValuePairToOutputDictionary "my_key" "my_value"
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias("k", "Key")]
        [string]$key,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [Alias("v", "Value")]
        [string]$value
    )

    Add-Member -InputObject $outputs -NotePropertyName $key -NotePropertyValue $value -Force -PassThru
}

function Add-SuccessStatusToOutputDictionary {
    <#
    .SYNOPSIS
    Adds a success status to the output dictionary.
    .DESCRIPTION
    Adds a predefined key-value pair for success status to the $outputs dictionary, initialized in the execution scope.
    .EXAMPLE
    Add-SuccessStatusToOutputDictionary
    #>
    Add-KeyValuePairToOutputDictionary $SYMPHONY_STATUS_FIELD $SUCCESS_SYMPHONY_CODE
}

function Add-ErrorStatusToOutputDictionary {
    <#
    .SYNOPSIS
    Adds an error status and an error field to the output dictionary.
    .DESCRIPTION
    Adds the input error value to the '__error' key and a predefined key-value pair for error status to the $outputs dictionary, initialized in the execution scope.
    .PARAMETER Error
    The input error value.
    .EXAMPLE
    Add-ErrorStatusToOutputDictionary -Error "my_error"
    .EXAMPLE
    Add-ErrorStatusToOutputDictionary -e "my_error"
    .EXAMPLE
    Add-ErrorStatusToOutputDictionary "my_error"
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias("e", "Error")]
        [string]$errorValue
    )

    Add-KeyValuePairToOutputDictionary $SYMPHONY_STATUS_FIELD $ERROR_SYMPHONY_CODE
    Add-KeyValuePairToOutputDictionary $SYMPHONY_ERROR_FIELD $errorValue
}

function Write-OutputDictionaryToOutputFile {
    <#
    .SYNOPSIS
    Writes the output dictionary to the output file.
    .DESCRIPTION
    Writes the $outputs dictionary, to the output file specified by the $output_file_path variable, initialized in the execution scope.
    .EXAMPLE
    Write-OutputDictionaryToOutputFile
    #>
    $outputs | Out-File -FilePath $output_file_path -Force 
}

function Invoke-CommandWithStatusCode {
    <#
    .SYNOPSIS
    Executes a command and captures the output and status code.
    .DESCRIPTION
    Executes the input command and captures the output and status code in the input variables.
    .PARAMETER Command
    The input command to execute.
    .PARAMETER OutVariable
    The output variable to capture the command output.
    .PARAMETER OutStatus
    The output variable to capture the command status code.
    .EXAMPLE
    Invoke-CommandWithStatusCode -Command "Write-Host 'Hello, World!'" -OutVariable $command_output -OutStatus $command_status
    .EXAMPLE
    Invoke-CommandWithStatusCode -c "Write-Host 'Hello, World!'" -o $command_output -s $command_status
    .EXAMPLE
    Invoke-CommandWithStatusCode "Write-Host 'Hello, World!'" $command_output $command_status
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias("c", "Command")]
        [string]$command,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [Alias("o", "OutVariable")]
        [ref]$base_command_output,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [Alias("s", "OutStatus")]
        [ref]$base_command_status
    )

    # Execute the command and capture output
    $base_command_output.Value = Invoke-Expression $command 2>&1
    $base_command_status.Value = $LASTEXITCODE

    if ($base_command_status.Value -ne 0) {
        Add-ErrorStatusToOutputDictionary $base_command_output.Value
    }
    else {
        Add-SuccessStatusToOutputDictionary
    }
}

function Invoke-Command-ExitOnFailure {
    <#
    .SYNOPSIS
    Executes a command and exits on failure.
    .DESCRIPTION
    Executes the input command and captures the output and status code in the input variables.
    If the input command fails, the function writes the $outputs dictionary to the output file and exits.
    .PARAMETER Command
    The input command to execute.
    .PARAMETER OutVariable
    The output variable to capture the command output.
    .PARAMETER OutStatus
    The output variable to capture the command status code.
    .EXAMPLE
    Invoke-Command-ExitOnFailure -Command "Write-Host 'Hello, World!'" -OutVariable $command_output -OutStatus $command_status
    .EXAMPLE
    Invoke-Command-ExitOnFailure -c "Write-Host 'Hello, World!'" -o $command_output -s $command_status
    .EXAMPLE
    Invoke-Command-ExitOnFailure "Write-Host 'Hello, World!'" $command_output $command_status
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias("c", "Command")]
        [string]$command,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [Alias("o", "OutVariable")]
        [ref]$command_output,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [Alias("s", "OutStatus")]
        [ref]$command_status
    )

    Invoke-CommandWithStatusCode -c $command -o $command_output -s $command_status

    if ($command_status.Value -ne 0) {
        Write-OutputDictionaryToOutputFile
        exit $command_status.Value
    }
}
#endregion Define functions


$inputs_file = $args[0]

$outputs = (Get-Content $inputs_file | ConvertFrom-Json | ForEach-Object { $_ | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value -PassThru -Force }) | ConvertTo-Json -Compress

$output_file_path = $inputs_file -replace '\.[^.]+$', '-output.$&'
