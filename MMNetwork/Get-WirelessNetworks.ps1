﻿# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 24-Jun-2015.

#requires -version 3

<#
.SYNOPSIS
    List wireless networks

.DESCRIPTION
    Uses netsh wlan to get wireless network information in Powershell friendly way.
.PARAMETER $List
    Ccontrols if results are passed to format-table cmdlet or not.
#>
function Get-WirelessNetworks([switch]$List) {

    if ((gwmi win32_operatingsystem).Version.Split(".")[0] -lt 6) { throw "Requires Windows Vista or higher." }
    if ((gsv "wlansvc").Status -ne "Running" ) { throw "Wlan service is not running." }

    $ifaces = netsh wlan show interfaces | sls '^\s*Name\s*:\s*(.+)\s*' | % { $_.matches[0].Groups[1].Value }

    $props = @( 'SSID', 'Authentication', 'Encryption', 'Signal', 'Radiotype', 'Channel', 'BSSID', 'Interface' )
    $nt = "" | select -Property $props
    $n  = $nt.PSObject.Copy()
    $results = @()
    $ifaces | % {
        $iface = $_
        netsh wlan show network mode=bssid interface="$iface" | select -Skip 4 | % {
            if (!$_) { $n.Interface = $iface; $results += $n; $n = $nt.PSObject.Copy(); return }
            $a =  $_ -split ' : '
            $p = $a[0].Trim() -replace '[ \d]*'; $v = $a[1].Trim()
            if ($props -contains $p) { $n.$p = $v }
        }
    }
    $r = $results | sort {[int]($_.Signal -replace "%")} -Descending
    if ($List) { $r } else { $r | ft }
}