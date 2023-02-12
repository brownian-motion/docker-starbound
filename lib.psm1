#!/usr/bin/env pwsh

function Invoke-SteamCmd([Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string[]] $Command) {
    /usr/games/steamcmd @Cmd
}

function Install-StarboundServer ([Parameter(Mandatory=$true)][string]$SteamUsername) {
    If ( -Not (Test-UpdateLock) ) {
        throw "cannot update server without /.update lock"
    }

    # Hack to remove cached auth details that stops the password prompt from appearing
    if ( Test-Path -Path /root/Steam/config/config.vdf ) {
        sed -i '/"ConnectCache"/,/}/d' /root/Steam/config/config.vdf
    }

    Invoke-SteamCmd `
        +force_install_dir /starbound/ `
        +login $SteamUsername `
        +app_update 211820 validate `
        +quit
}

function Get-StarboundMods ([string]$SteamUsername, [string[]]$ModIds) {
    If ( -Not (Test-UpdateLock) ) {
        throw "cannot update mods without /.update lock"
    }

    $cmd = @('+force_install_dir', '/starbound/', '+login', $SteamUsername)
    foreach ($modId in $ModIds) {
        $cmd += "+workshop_download_item"
        $cmd += '211820'
        $cmd += $modId
    }
    $cmd += '+quit'

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
        Remove-Item -Force -Recurse "/starbound/mods/$modId" -ErrorAction SilentlyContinue
        Copy-Item -Container -Recurse "/starbound/steamapps/workshop/content/211820/$modId" "/starbound/mods/$modId"
    }
}

function Test-UpdateLock() {
    return Test-Path -Path /.update -PathType Leaf
}

function Lock-UpdateLock() {
    Stop-StarboundService
    touch /.update
}

function Unlock-UpdateLock() {
    rm /.update
}

function Stop-StarboundService() {
    $PID=(pidof "/starbound/linux/starbound_server")

    if ( $null -ne $PID -And "" -ne $PID ) {
        kill $PID
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
    throw "Starbound not installed"
  }

  if ( Test-UpdateLock ){
    throw "locked for update"
  }

  $extraFlags = Get-StarboundConfigOverrideFlags 

  Set-Location '/starbound/linux'
  ./starbound_server @extraFlags
}

function Wait-ForStarboundUpdate() {
  while (Test-Path -Path '/.update' ) {
    Start-Sleep -Seconds 10
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

