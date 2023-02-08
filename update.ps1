#!/usr/bin/env pwsh

. lib.ps1

Lock-UpdateLock

Install-StarboundServer -SteamUsername (Get-SteamUsername)
Install-StarboundMods -ModIds (Get-ModIds)

Unlock-UpdateLock