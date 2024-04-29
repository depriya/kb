param (
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$ContainerName,

    [Parameter(Mandatory=$true)]
    [string]$AccountKey,

    [Parameter(Mandatory=$true)]
    [string]$localFolderPath
)
# Install the packages required
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Az.Storage -Force

# Give the connection string.
$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$AccountKey"
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString


$filesToUpload = Get-ChildItem -Path $localFolderPath -File -Recurse
$lastDirectory = (Split-Path $localFolderPath -Leaf)
# Upload each file to the storage container
foreach ($file in $filesToUpload) {
    $relativePath = $file.FullName.Substring($localFolderPath.Length + 1)
    $blobPath = Join-Path -Path $lastDirectory -ChildPath $relativePath.Replace('\', '/')
    Set-AzStorageBlobContent -Container $ContainerName -Blob $blobPath -File $file.FullName -Context $Ctx -Force
    Write-Host "Uploaded $($file.FullName) to $blobPath"
}

Write-Host "All files and folders under $localFolderPath have been uploaded to the storage container."