<#
.SYNOPSIS
Waits for a specified browser element to be present then returns that element.

.DESCRIPTION
Waits until an element is present in the given Internet Explorer object's document contents and then
returns that element. Can also require certain attribute criteria.

.PARAMETER IEObject
An Internet Explorer object where the element should be present.

.PARAMETER TagName
The HTML tag name to look for.

.PARAMETER Attributes
A list of attribute names and values that the element should have.

.EXAMPLE
$splat =
@{
    IEObject = $ieobject
    TagName = 'DIV'
    Attributes = @{
        ClassName = 'oauth-verifier'
    }
}
PS C:\> Wait-ForElement @splat
className                    : oauth-verifier
id                           : 
tagName                      : DIV
parentElement                : System.__ComObject
style                        : System.__ComObject
...
This will wait for a DIV tag where the class is 'oauth-verifier'.

.NOTES
General notes
#>
function Wait-ForElement {
    param (
        $IEObject,
        [string]$TagName,
        [hashtable]$Attributes
    )

    do {
        $results = Get-Element -IEObject $IEObject -TagName $TagName -Attributes $Attributes
        Start-Sleep -Milliseconds 500
    }
    while ($null -eq $results)
    #return
    $results
}