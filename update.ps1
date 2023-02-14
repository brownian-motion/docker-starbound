#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, Position=0)][string]$SteamUsername,
    [Parameter(Mandatory=$false, Position=1)][string]$SteamPassword
)

Import-Module -Name '/lib'

Lock-UpdateLock

if ($null -eq $SteamUsername -Or "" -eq $SteamUsername) {
    $SteamUsername = Get-SteamUsername
}

Install-StarboundServer -SteamUsername $SteamUsername
Install-StarboundMods -ModIds (Get-ModIds)

Unlock-UpdateLock
