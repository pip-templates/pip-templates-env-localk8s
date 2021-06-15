#!/usr/bin/env pwsh

param
(
    [Alias("c", "Config")]
    [Parameter(Mandatory=$true, Position=0)]
    [string] $ConfigPath,

    [Parameter(Mandatory=$false, Position=1)]
    [string] $ConfigPrefix = "k8s",

    [Alias("r", "Resources")]
    [Parameter(Mandatory=$false, Position=2)]
    [string] $ResourcePath,

    [Parameter(Mandatory=$false, Position=3)]
    [string] $ResourcePrefix
)

# Stop on error
$ErrorActionPreference = "Stop"

# Load support functions
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }
. "$($path)/../common/include.ps1"
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

# Set default parameter values
if (($ResourcePath -eq $null) -or ($ResourcePath -eq ""))
{
    $ResourcePath = ConvertTo-EnvResourcePath -ConfigPath $ConfigPath
}
if (($ResourcePrefix -eq $null) -or ($ResourcePrefix -eq "")) 
{ 
    $ResourcePrefix = $ConfigPrefix 
}

# Read config and resources
$config = Read-EnvConfig -ConfigPath $ConfigPath
$resources = Read-EnvResources -ResourcePath $ResourcePath

###################################################################\
# Skip if resource wasn't created
if ((Test-EnvMapValue -Map $resources -Key "$ResourcePrefix") -and (Test-EnvMapValue -Map $resources -Key "$ResourcePrefix.type"))
{
    # Notify user about start of the task
    Write-Host "`n***** Started deleting k8s cluster. *****`n"

    # Destroy minikube
    minikube delete

    # Check for error
    if ($LastExitCode -ne 0) 
    {
        Write-Host "There were errors deleting minikube, Watch logs above" -ForegroundColor Red
        exit 0
    }

    # Delete results and save resource file to disk
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.type"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.address"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.ssh_key"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.driver"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.memory"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.version"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.cpus"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.blobs_storage_gb"
    Remove-EnvMapValue -Map $resources -Key "$ResourcePrefix.namespace"

    Write-EnvResources -ResourcePath $ResourcePath -Resources $resources
}
else 
{
    Write-Host "K8S cluster doesn't exists. Deletion skipped."
    exit 0
}
###################################################################
