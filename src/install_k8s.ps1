#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$true, Position=0)]
    [string] $ConfigPath,
    [Alias("p")]
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Prefix
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

# Set default values for config parameters
if ($config.k8s_driver -eq $null) {
    $config.k8s_driver = "virtualbox"
}
if ($config.k8s_version -eq $null) {
    $config.k8s_version = "v1.8.0"
}
if ($config.k8s_driver -eq "hyperv") {
    if ($config.k8s_hyperv_switch -eq $null) {
        throw "Create Hyper-V Switch and set k8s_hyperv_switch setting. Refer to https://blogs.msdn.microsoft.com/wasimbloch/2017/01/23/setting-up-kubernetes-on-windows10-laptop-with-minikube/"
    }
    $switches = "--hyperv-virtual-switch=$($config.k8s_hyperv_switch)"
}

if ($config.minikube_home -ne "") {
    $env:MINIKUBE_HOME = $config.minikube_home
}

# Start minikube
minikube start --cpus $($config.k8s_cpus) `
    --memory $($config.k8s_memory) `
    --vm-driver=$($config.k8s_driver) `
    $switches `
    --kubernetes-version=$($config.k8s_version)

# Read minikube IP address
$out = (minikube ssh "ifconfig eth1") | Out-String
$out -match ".*inet addr:(?<addr>\S*).*" | Out-Null
$k8s_address = $matches.addr

# Read minikube ssh key
$out = (minikube ssh-key) | Out-String
$k8s_ssh_key = $out.Replace("`r", "").Replace("`n", "")

# Write k8s resources
$resources.k8s_type = "minikube"
$resources.k8s_nodes = @($k8s_address)
$resources.k8s_address = $k8s_address

Write-EnvResources -Path $ConfigPath -Resources $resources
