<#
.SYNOPSIS
Creates an arbitrary string of characters.

.DESCRIPTION
Creates an arbitrary string of characters.

.EXAMPLE
New-Nonce
NjM2MzQyODMwODY3NDIxODg4

#>
function New-Nonce {
    [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes((Get-Date).Ticks))
}