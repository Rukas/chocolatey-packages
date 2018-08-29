$ErrorActionPreference = 'Stop';

$packageName= 'heartbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-6.4.0-windows-x86.zip'
$url64      = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-6.4.0-windows-x86_64.zip'

$installationPath = $toolsDir

# Chocolatey seems to copy the old lib folder in case of upgrade. Uninstall first.
$zipContentGlob=dir "$($installationPath)/.." "filebeat-*.zip.txt"
$zipContentFile=$zipContentGlob.Name
$folder = ($zipContentFile -replace ".zip.txt","") + "\\"
if (($zipContentGlob -ne $null)) {
    $zipContentFile
    $zipContents=(get-content $zipContentGlob.FullName) -split [environment]::NewLine
    for ($i = $zipContents.Length; $i -gt 0; $i--) {
        $fileInZip = $zipContents[$i]
        if ($fileInZip -ne $null -and $fileInZip.Trim() -ne '') {
            $fileToRemove = $fileInZip -replace $folder,""
            Remove-Item -Path "$fileToRemove" -ErrorAction SilentlyContinue -Recurse -Force
        }
    }
    Remove-Item -Path $zipContentGlob.FullName -ErrorAction SilentlyContinue -Recurse -Force
}

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = 'd620984d6652ade7e3e8ddfdce0bf7527da2ea6abee43c9110104e0cfcdc02e87e20f0dd0eb219edfb3688bcee7ab76e4aa60b30d897e31e3e8d6c063d40f342'
  checksumType  = 'sha512'
  checksum64    = '459a1463795f08f784ed81d03304e0464534e9911951be04de8615a34684f4d2a42b7bbf69ee168714301ef9da06b6cc1339e523a1612388d21c12cff6fce33c'
  checksumType64= 'sha512'
  specificFolder = $folder
}

Install-ChocolateyZipPackage @packageArgs

# Move everything from the subfolder to the main tools directory
$subFolder = Join-Path $installationPath (Get-ChildItem $installationPath $folder | ?{ $_.PSIsContainer })
Get-ChildItem $subFolder -Recurse | ?{$_.PSIsContainer } | Move-Item -Destination $installationPath
Get-ChildItem $subFolder | ?{$_.PSIsContainer -eq $false } | Move-Item -Destination $installationPath
Remove-Item "$subFolder"

Invoke-Expression $(Join-Path $installationPath "install-service-$($packageName).ps1")
