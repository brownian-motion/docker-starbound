#!/usr/bin/env pwsh

function Invoke-SteamCmd([Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string[]] $Command) {
    Write-Verbose "Running Steam command with args $Command"
    /usr/games/steamcmd @Cmd
}

function Install-StarboundServer ([Parameter(Mandatory=$true)][string]$SteamUsername) {
    If ( -Not (Test-UpdateLock) ) {
        throw "cannot update server without /.update lock"
    }

    # Hack to remove cached auth details that stops the password prompt from appearing
    if ( Test-Path -Path /root/Steam/config/config.vdf ) {
        Write-Verbose "Removing 'ConnectCache' config that blocks password prompt"
        sed -i '/"ConnectCache"/,/}/d' /root/Steam/config/config.vdf
    }

    Write-Verbose "Installing & validating Starbound install"
    Invoke-SteamCmd `
        "+force_install_dir /starbound/" `
        "+login $SteamUsername" `
        "+app_update 211820 validate" `
        "+quit"
}

function Get-StarboundMods ([string]$SteamUsername, [string[]]$ModIds) {
    If ( -Not (Test-UpdateLock) ) {
        throw "cannot update mods without /.update lock"
    }

    $cmd = @('+force_install_dir /starbound/', "+login $SteamUsername")
    foreach ($modId in $ModIds) {
        $cmd += "+workshop_download_item 211820 $modId"
    }
    $cmd += '+quit'

    Write-Verbose "Installing mods..."
    Invoke-SteamCmd $cmd
}

function Install-StarboundMods ([string[]]$ModIds) {
    If ( -Not (Test-UpdateLock) ) {
        throw "cannot update mods without /.update lock"
    }

    Get-StarboundMods -SteamUsername (Get-SteamUsername) -ModIds:$ModIds

    Install-DownloadedStarboundMods -ModIds:$ModIds
}

function Install-DownloadedStarboundMods([string[]]$ModIds){
    foreach ($modId in $ModIds) {
        Write-Verbose "Removing any existing install for mod $modId"
        Remove-Item -Force -Recurse "/starbound/mods/$modId" -ErrorAction SilentlyContinue

        Write-Verbose "Installing downloaded mod $modId to /starbound"
        Copy-Item -Container -Recurse "/starbound/steamapps/workshop/content/211820/$modId" "/starbound/mods/$modId"
    }
}

function Test-UpdateLock() {
    return Test-Path -Path /.update -PathType Leaf
}

function Lock-UpdateLock() {
    If ((Test-UpdateLock)) {
        return
    }
    Write-Verbose "Locking for updates"
    Stop-StarboundService
    touch /.update
    if (-Not (Test-UpdateLock)) {
        throw "Could not lock before update"
    }
}

function Unlock-UpdateLock() {
    If (-Not (Test-UpdateLock)){
        return
    }
    Remove-Item -Path /.update
    Write-Verbose "Unlocking after updates"
    if (Test-UpdateLock) {
        throw "Could not unlock after update"
    }
}

function Stop-StarboundService() {
    Write-Verbose "Stopping starbound server..."
    $PID=(pidof "/starbound/linux/starbound_server")

    if ( $null -ne $PID -And "" -ne $PID ) {
        Write-Verbose "  Killing starbound server"
        kill $PID
    } else {
        Write-Verbose "  No starbound server is running"
    }
}

function Test-ModInstalled([ValidatePattern("\d+")][string]$ModId) {
  return Test-Path '/starbound/mods/$ModId' -PathType Container
}

function Get-ModIds() {
    return $env:MOD_IDS -split ',' | Where { $null -ne $_ -And "" -ne $_ }
}

function Test-StarboundInstalled() {
  return Test-Path -Path '/starbound/linux/starbound_server' -PathType Leaf
}

function Start-StarboundServer() {
  if ( -Not (Test-StarboundInstalled) ) {
    throw "Starbound not installed, please run /update.ps1 for initial install"
  }

  if ( Test-UpdateLock ){
    throw "Locked for update, please run /update.ps1 for initial install or update"
  }

  $extraFlags = Get-StarboundConfigOverrideFlags 

  Invoke-StarboundServer -Args $extraFlags
}

function Invoke-StarboundServer([string[]]$Args) {
  Write-Verbose "Running starbound server with args $Args"
  Set-Location '/starbound/linux'
  ./starbound_server @Args
  return $LASTEXITCODE
}

function Wait-ForStarboundUpdate() {
  Write-Verbose "Initial check for /.update lock..."
  while (Test-Path -Path '/.update' ) {
    Write-Verbose "  Locked for update. Sleeping..."
    Start-Sleep -Seconds 10
    Write-Verbose "  Checking for /.update lock..."
  }
}

function Get-SteamUsername() {
    if ($null -eq $env:STEAM_USERNAME -Or "" -eq $env:STEAM_USERNAME) {
        return "anonymous"
    }

    return $env:STEAM_USERNAME
}

function Get-StarboundConfigOverrides() {
    Get-Item -Path Env:\STARBOUND_* | % {
        return @{
            Name = $_.Name.Substring(10); # remove "STARBOUND_"
            Value = $_.Value;
        }
    } | Sort-Object -Property Name # predictable ordering for tests
}

function Get-StarboundConfigOverrideFlags() {
    # SEE https://www.reddit.com/r/starbound/comments/34p6m1/is_there_a_list_of_command_line_arguments_that/
    $out = @()
    foreach($override in (Get-StarboundConfigOverrides)) {
        $out += '-setconfig'
        $out += "$($override.Name):$($override.Value)"
    }
    return $out
}

