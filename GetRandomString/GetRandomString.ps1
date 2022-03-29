function Get-Random-String {
    <#    
    .SYNOPSIS
    Generates a random string with an array of customisations
    #>

    <#    
    .DESCRIPTION
    This cmdlet generates a random string based on user customisation.
    #>

  [CmdletBinding()]
  [Alias('rndmstr')]
  param(
    <#    
    .EXAMPLE
    rndmstr 32 
    ukmshszqvkwhivrevecpsrnqnvpjuvpkt
    #>

    <#    
    .EXAMPLE
    rndmstr 32 -UseUpperCase
    LSlBajOMOAsyCeHipDWOiblIbiOrGSkfu
    #>
    <#    
    .EXAMPLE
    rndmstr 32 -UseUpperCase -UseNumbers
    FYyU7bIUoFKJr3975ZAJc8jeCnVhjlZqT
    #>

    <#    
    .EXAMPLE
    rndmstr 32 -UseUpperCase -UseLoweCase:$false
    ARKDMQJFILYWYTAZNSRQOUFYLFTMIZEWV
    #>

    <#    
    .EXAMPLE
    rndmstr 32 -UseUpperCase -UseNumbers -UseSpecialCharacters
    bFNC1D1K*ng37neaYYpT0J985+ZCaC47h
    #>
         
    

    [Parameter(        
        Mandatory=$true,
        HelpMessage="The character length of the requested random string"
    )]
    [int] $StringLength,

    [Parameter(HelpMessage="Adds Lower-Case latin characters to the string pool")]
    [switch] $UseLowerCase = $true,

    [Parameter(HelpMessage="Adds Upper-Case latin characters to the string pool")]
    [switch] $UseUpperCase = $false,

    [Parameter(HelpMessage="Adds numeric characters to the string pool")]
    [switch] $UseNumbers = $false,

    [Parameter(HelpMessage="Adds the special characters: '!@#$%^&*_+-' to the string pool")]
    [switch] $UseSpecialCharacters = $false,

    [Parameter(HelpMessage="Characters here will be added to the string pool")]
    [string] $IncludeCharacters = "",

    [Parameter(HelpMessage="Characters here will be removed to the string pool")]
    [string] $ExcludeCharacters = ""
  )
    if(
     !($UseLowerCase) -and
     !($UseUpperCase) -and
     !($UseNumbers) -and
     !($UseSpecialCharacters) -and
     ($IncludeCharacters -eq "")
     ){
        throw "No Characters allowed. Please use some of the parameter flags to enable character sets."
     }
    # Initate character sets
    $Letters = "ABCDEFGHIJKLMNOPQRSTUVWYZ"
    $Numbers = "0123456789"
    $SpecialCharacters = "!@#$%^&*_+-"
    
    # Populate the pool so that each character has a chance to be picked
    $Pool = ""
    for ($i = 0 ; $i -lt $StringLength ; $i++){
        if($UseUpperCase) {$Pool+=$Letters}
        if($UseLowerCase) {$Pool+=$Letters.ToLower()}
        if($UseNumbers){$Pool+=$Numbers }
        if($UseSpecialCharacters){$Pool+=$SpecialCharacters}
        $Pool+=$IncludeCharacters
    }

    # Remove Excluded characters
    foreach ($Char in $ExcludeCharacters.toCharArray()) {
       $Pool = $Pool -replace '['+$Char+']',''
    }
    if($Pool -eq ""){
        throw "No Characters allowed. All available characters were excluded by user."
    }

    # Sort by Get-Random to shuffle (Get-Random is a secure random)
    $Shuffle = $($Pool.tochararray() | Sort-Object {Get-Random})
    
    # Return the first N charachters as a string
    return $Shuffle[0..$StringLength] -join ''
}



