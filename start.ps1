#!/usr/bin/env pwsh

[CmdletBinding()]param()

Import-Module -Name '/lib'

if ( Test-StarboundInstalled ) {
  Start-StarboundServer
}

Wait-ForStarboundUpdate

exit

