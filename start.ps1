#!/usr/bin/env pwsh

[CmdletBinding()]param()

Import-Module -Name '/lib'

if ( Test-StarboundInstalled ) {
  Start-StarboundServer
} else {
  Lock-UpdateLock
}

Wait-ForStarboundUpdate

exit

