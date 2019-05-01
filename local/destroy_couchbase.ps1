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

# Destroy cluster
### cbopctl contains validation, but not execute from powershell on windows, so use kubectl
# . "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/bin/cbopctl" delete -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/couchbase-cluster.yaml"
kubectl delete -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/couchbase-cluster.yaml"

# Delete secret
kubectl delete -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/secret.yaml"

# Delete Couchbase Operator
kubectl delete -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/operator.yaml"
kubectl delete clusterrolebinding couchbase-operator 
kubectl delete serviceaccount couchbase-operator --namespace default
kubectl delete -f "$($path)/../temp/couchbase-autonomous-operator-kubernetes/couchbase-autonomous-operator-kubernetes_1.1.0-541_windows-amd64/cluster-role.yaml"
