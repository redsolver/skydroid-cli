#!/usr/bin/env pwsh
# Based on Deno installer: Copyright 2018 the Deno authors. All rights reserved. MIT license.
# TODO(everyone): Keep this script simple and easily auditable.

$ErrorActionPreference = 'Stop'

if ($v) {
  $Version = "v${v}"
}
if ($args.Length -eq 1) {
  $Version = $args.Get(0)
}

$BinDir = "$Home\AppData\local\skydroid"

$CliExe = "$BinDir\skydroid.exe"
$Target = 'windows.exe'

# GitHub requires TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$CliUri = if (!$Version) {
  "https://github.com/redsolver/skydroid-cli/releases/latest/download/skydroid-${Target}"
} else {
  "https://github.com/redsolver/skydroid-cli/releases/download/${Version}/skydroid-${Target}"
}

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}

Invoke-WebRequest $CliUri -OutFile $CliExe -UseBasicParsing

$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
  [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
  $Env:Path += ";$BinDir"
}

Write-Output "The SkyDroid CLI was installed successfully to $CliExe"
Write-Output "Run 'skydroid --help' to get started"