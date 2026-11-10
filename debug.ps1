& (Join-Path $PSScriptRoot 'build.ps1') -Task Build
& (Join-Path $PSScriptRoot 'ModuleDebug.ps1')
