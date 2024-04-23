param (
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$ContainerName,

    [Parameter(Mandatory = $true)]
    [string]$AccountKey,

    [Parameter(Mandatory = $true)]
    [string]$FileName,

    [Parameter(Mandatory = $false)]
    [string]$localTargetDirectory = "C:\Temp"
)

# Install the packages required
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Az.Storage -Force

# Give the connection string.
$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$AccountKey"
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString

# Download Blob to the Destination Path
Get-AzStorageBlobContent -Blob $FileName -Container $ContainerName -Destination $localTargetDirectory -Context $Ctx -Force