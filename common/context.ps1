function Switch-KubeContext
{
    $currentContext = kubectl config current-context
    if ($currentContext -ne "minikube") 
    {
        kubectl config use-context minikube

        if ($LastExitCode -ne 0) 
        {
            Write-Error "There were errors switching to minikube context, Watch logs above"
            exit 0
        }
    }
}
