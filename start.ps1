#!/usr/bin/env pwsh

Import-Module -Name '/lib'

if ( Test-StarboundInstalled ) {
  Start-StarboundServer
}

Wait-ForStarboundUpdate

exit

