function Split-Parameter {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Parameter
    )

    foreach ($param in $Parameter.Split('&')) {
        $pieces = $param.Split('=')
        [PSCustomObject]@{
            Name=$pieces[0]
            Value=$pieces[1]
        }
    }
}