function Get-Element {
    param (
        $IEObject,
        [string]$TagName,
        [hashtable]$Attributes
    )
    
    # Wrap results in array so that the Where method is available which processes faster than Where-Object.
    try {
        $elements = @($IEObject.Document.IHTMLDocument3_getElementsByTagName($TagName))
        $array = New-Object -TypeName System.Collections.ArrayList
        $template = '$_.{0} -eq "{1}"'
        foreach ($key in $Attributes.Keys) {
            $condition = $template -f $key, $Attributes.$key
            $array.Add($condition) > $null
        }
        $scriptBlock = [scriptblock]::Create($array -join ' -and ')
        #return
        $elements.Where($scriptBlock)
    }
    catch [System.Management.Automation.RuntimeException] {
        Write-Warning 'Browser closed unexpectedly.'
    }
    catch {
        Write-Error 'An unexpected error occurred.'
    }
}