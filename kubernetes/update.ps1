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

###################################################################
# Skip if resource wasn't created
if ((Test-EnvMapValue -Map $resources -Key "$ResourcePrefix") -and (Test-EnvMapValue -Map $resources -Key "$ResourcePrefix.type"))
{
    # Verify if k8s configuratuion changed
    if (
        (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.version") -ne (Get-EnvMapValue -Map $config -Key "$ConfigPrefix.version") -or
        (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.driver") -ne (Get-EnvMapValue -Map $config -Key "$ConfigPrefix.driver") -or
        (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.memory") -ne (Get-EnvMapValue -Map $config -Key "$ConfigPrefix.memory") -or
        (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.cpus") -ne (Get-EnvMapValue -Map $config -Key "$ConfigPrefix.cpus") -or
        (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.namespace") -ne (Get-EnvMapValue -Map $config -Key "$ConfigPrefix.namespace") -or
        (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.blobs_storage_gb") -ne (Get-EnvMapValue -Map $config -Key "$ConfigPrefix.blobs_storage_gb")
    ) 
    {
        Write-Error "Kubernetes configuration changed, to update the environment you need to entirely delete it (delete_env.ps1) and recreate it (create_env.ps1)."
    }
}
else
{
    Write-Error "Can't execute update script - component must be created before running update script."
}
###################################################################
