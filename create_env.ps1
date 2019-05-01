#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$false, Position=0)]
    [string] $ConfigPath
)

$ErrorActionPreference = "Stop"

# Load support functions
$rootPath = $PSScriptRoot
if ($rootPath -eq "") { $rootPath = "." }
. "$($rootPath)/lib/include.ps1"
$rootPath = $PSScriptRoot
if ($rootPath -eq "") { $rootPath = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

switch ($config.env_type) {
    "local" { 
        . "$($rootPath)/local/install_k8s.ps1" $ConfigPath
        . "$($rootPath)/local/configure_k8s.ps1" $ConfigPath
     }
     Default {
         Write-Host "Platform type not specified in config file. Please add 'env_type' to config."
     }
}
