#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$false, Position=0)]
    [string] $ConfigPath
)

$ErrorActionPreference = "Stop"

# Load support functions
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }
. "$($path)/../lib/include.ps1"
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

# Destroy minikube
minikube delete

#rm -rf ~/.minikube

# Write k8s resources
$resources.k8s_type = ""
$resources.k8s_nodes = ""
$resources.k8s_address = ""

Write-EnvResources -Path $ConfigPath -Resources $resources