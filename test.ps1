#!/usr/bin/env pwsh

Import-Module Pester

$initialEnv = Get-Item Env:

Invoke-Pester '/tests' -EnableExit

