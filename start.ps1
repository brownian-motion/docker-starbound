#!/usr/bin/env pwsh

. lib.ps1

if ( Test-StarboundInstalled ) {
  Start-StarboundServer
}

Wait-ForStarboundUpdate

exit
