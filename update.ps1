#!/usr/bin/env pwsh

Import-Module -Name '/lib'

Lock-UpdateLock

Install-StarboundServer -SteamUsername (Get-SteamUsername)
Install-StarboundMods -ModIds (Get-ModIds)

Unlock-UpdateLock
