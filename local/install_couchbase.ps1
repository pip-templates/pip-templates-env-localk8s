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

Write-Host "Installing couchbase..."

# Download Couchbase Operator package
if (!(Test-Path "$($path)/../temp/couchbase-autonomous-operator-kubernetes_1.1.0-windows_amd64.zip")) {
    $url = "https://s3.amazonaws.com/packages.couchbase.com/kubernetes/1.1.0/couchbase-autonomous-operator-kubernetes_1.1.0-windows_amd64.zip"
    $output = "$($path)/../temp/couchbase-autonomous-operator-kubernetes_1.1.0-windows_amd64.zip"
    Invoke-WebRequest -Uri $url -OutFile $output
}

# Unzip Couchbase Operator package. need to skip /../
if (!(Test-Path "$($path)/../temp/couchbase-autonomous-operator-kubernetes")) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$($path)/../temp/couchbase-autonomous-operator-kubernetes_1.1.0-windows_amd64.zip", "$($path)/../temp/couchbase-autonomous-operator-kubernetes")
}

# Install Couchbase Operator
kubectl create -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/cluster-role.yaml"
kubectl create serviceaccount couchbase-operator --namespace default
kubectl create clusterrolebinding couchbase-operator --clusterrole couchbase-operator --serviceaccount default:couchbase-operator
kubectl create -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/operator.yaml"

# Wait for couchbase operator to establish a connection to k8s master node
Write-Host "Waiting for Couchbase Operator deployment..."
do {
    Start-Sleep -Seconds 5

    $desired = kubectl get deployments -l app=couchbase-operator | tail -n +2 | awk '{print $2}'
    $available = kubectl get deployments -l app=couchbase-operator | tail -n +2 | awk '{print $5}'
}
while ($desired -ne $available)

# Install Couchbase Server

# Create secret with auth credentials
kubectl create -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/secret.yaml"

# Install cluster 
### cbopctl contains validation, but not execute from powershell on windows, so use kubectl
#. "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/bin/cbopctl" create -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/couchbase-cluster.yaml"
kubectl create -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/couchbase-cluster.yaml"
