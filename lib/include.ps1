$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

. "$($path)/convert.ps1"
. "$($path)/config.ps1"
. "$($path)/templates.ps1"
