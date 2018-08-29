$packageName= 'heartbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$uninstallScript = Join-Path $toolsDir "uninstall-service-heartbeat.ps1"

Invoke-Expression $uninstallScript
