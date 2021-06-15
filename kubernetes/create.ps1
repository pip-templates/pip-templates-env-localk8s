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
# Verify if k8s cluster was created
if (!((Test-EnvMapValue -Map $resources -Key "$ResourcePrefix") -and (Test-EnvMapValue -Map $resources -Key "$ResourcePrefix.type")))
{
    Write-Host "`n***** Started creating k8s cluster. *****`n"
    $cpus = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.cpus"
    $memory = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.memory"
    $driver = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.driver"
    $version = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.version"
    $minikube_home = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.minikube_home"
    $namespace = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.namespace"
    $blobs_storage_gb = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.blobs_storage_gb"

    # Set default values for config parameters
    if ($driver -eq "hyperv") 
    {
        $hyperv_switch = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.hyperv_switch"
        if ($hyperv_switch -eq $null) 
        {
            throw "Create Hyper-V Switch and set k8s.hyperv_switch setting. Refer to https://blogs.msdn.microsoft.com/wasimbloch/2017/01/23/setting-up-kubernetes-on-windows10-laptop-with-minikube/"
            
        }
        $switches = "--hyperv-virtual-switch=$($hyperv_switch)"
    }

    # Set minikube home directory
    if ($minikube_home -ne "") 
    {
        $env:MINIKUBE_HOME = $minikube_home
    }

    # Compare installed version to version set in config
    $localMinikubeVersion = $(minikube version --short) -replace '(minikube version:) (.*)','$2'
    $setMinikubeVersion = Get-EnvMapValue -Map $config -Key "$ConfigPrefix.version"
    if ($localMinikubeVersion -gt $setMinikubeVersion)
    {
        Write-Error $("Locally installed minikube version ($localMinikubeVersion) is greater than the one set in the environment config ($setMinikubeVersion). " `
            + "Please update config's k8s.version to match the locally installed version.")
    }

    # Start minikube
    minikube start --cpus $($cpus) `
        --memory $($memory) `
        --driver=$($driver) `
        $switches `
        --kubernetes-version=$($version)

    if ($LastExitCode -ne 0)
    {
        Write-Error "There were errors starting minikube, Watch logs above"
    }

    $k8sAddress = (minikube ip)
    $k8sSshKey = (minikube ssh-key)

    # Record results and save them to disk
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.type" -Value "minikube"
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.address" -Value $k8sAddress
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.ssh_key" -Value $k8sSshKey
    # Record current k8s configuration to resoruces
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.version" -Value $version
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.driver" -Value $driver
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.memory" -Value $memory
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.cpus" -Value $cpus
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.namespace" -Value $namespace
    Set-EnvMapValue -Map $resources -Key "$ResourcePrefix.blobs_storage_gb" -Value $blobs_storage_gb

    Write-EnvResources -ResourcePath $ResourcePath -Resources $resources

    # Wait for minikube to start
    # Todo: rewrite to use "minikube status"
    do {
        Write-Host "Waiting for minikube to start..."
        Start-Sleep -Seconds 5
        $out = kubectl get nodes | Out-String
    } while (!($out.Contains("Ready")));

    # Notify user about end of the task
    Write-Host "`n***** Completed creating k8s cluster. *****`n"
    ###################################################################

    ###################################################################
    # Notify user about start of the task
    Write-Host "`n***** Started creating k8s namespace and blobs persistent volume. *****`n"
    $templateParams = @{ namespace=$namespace ; blobs_storage_gb=$blobs_storage_gb}
    # Set variables from config
    Build-EnvTemplate -InputPath "$($path)/templates/namespace.yml" -OutputPath "$($path)/../temp/namespace.yml" -Params1 $templateParams
    # Create k8s namespace
    kubectl apply -f "$($path)/../temp/namespace.yml"

    # Set variables from config
    Build-EnvTemplate -InputPath "$($path)/templates/blobs_pv.yml" -OutputPath "$($path)/../temp/blobs_pv.yml" -Params1 $templateParams
    # Create k8s blobs persistent volume
    kubectl apply -f "$($path)/../temp/blobs_pv.yml"

    # Notify user about end of the task
    Write-Host "`n***** Completed creating k8s namespace and blobs persistent volume. *****`n"
    ###################################################################
} 
else
{
    Write-Host "K8s cluster of type" (Get-EnvMapValue -Map $resources -Key "$ResourcePrefix.type") "exists. Skipping minikube creation" -ForegroundColor Red
    exit 0
}
###################################################################
