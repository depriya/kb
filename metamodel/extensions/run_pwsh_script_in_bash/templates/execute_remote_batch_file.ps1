param (
    [Parameter(Mandatory = $true)]
    [string]$FileName
)

Write-Host "Executing the batch file: $FileName"
Start-Process -FilePath "$FileName" -Wait -NoNewWindow
Write-Host "Batch file - $FileName execution completed"