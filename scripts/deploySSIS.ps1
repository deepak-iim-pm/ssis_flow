param(
    [string]$sqlServerName,
    [string]$isPacPath,
    [string]$folderName,
    [string]$projectName,
    [string]$authType = "Windows"  # Default to Windows Authentication
)

# Validate parameters
if (-not (Test-Path $isPacPath)) {
    Write-Error "The .ispac file path '$isPacPath' is invalid or does not exist."
    exit 1
}

# Load SSIS catalog assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null

# Connect to SSISDB
$serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($sqlServerName)
if ($authType -eq "SQL") {
    $serverConnection.LoginSecure = $false
    $serverConnection.Login = $env:SQL_USERNAME
    $serverConnection.Password = $env:SQL_PASSWORD
}

$ssisServer = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices($serverConnection)

# Deploy the project
$ssisCatalog = $ssisServer.Catalogs["SSISDB"]
$ssisCatalogFolder = $ssisCatalog.Folders[$folderName]

if (-not $ssisCatalogFolder) {
    $ssisCatalog.Folders.Add($folderName)
    $ssisCatalog.Folders[$folderName].Create()
}

$ssisProject = $ssisCatalogFolder.Projects[$projectName]
if ($ssisProject) {
    $ssisProject.Delete()
}

$ssisCatalogFolder.DeployProject($isPacPath, $projectName, $true)
Write-Host "SSIS Project deployed successfully."
# PowerShell script for SSIS deployment
