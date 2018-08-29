$packageName= 'heartbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$uninstallScript = $zipManifest | where { $_ -like "uninstall-*.ps1" }

Invoke-Expression $uninstallScript