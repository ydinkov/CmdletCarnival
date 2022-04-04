# ![](carousel.png) Nibblebit's Cmdlet Carnival! 🎈🎉🎊

A repository for storing all kinds of barely useful powershell cmdlets. Complete with a short doc descriptions and automatically pushed to nuget

Are they pretty? No!

Are they fun? Kinda...

Do I feel like figuring them out again every time I need something like that? Absolutely njet!

# Get-Random-String (Alias `rndmstr`) ![](GetRandomString/logo.png)


Returns a randomly generated string of a custom size. It allows for user customisation

```ps1

# Simple usage
rndmstr 32 
# returns
ukmshszqvkwhivrevecpsrnqnvpjuvpkt


# Adding upper case letters to the pool
rndmstr 32 -UseUpperCase
# returns
LSlBajOMOAsyCeHipDWOiblIbiOrGSkfu

# Adding upper case letters and numbers to the pool
rndmstr 32 -UseUpperCase -UseNumbers
# returns
FYyU7bIUoFKJr3975ZAJc8jeCnVhjlZqT


# Adding upper case letters and removing lower case letters from the pool
rndmstr 32 -UseUpperCase -UseLoweCase:$false
ARKDMQJFILYWYTAZNSRQOUFYLFTMIZEWV

# Adding upper case letters, numbers and special characters to the pool
rndmstr 32 -UseUpperCase -UseNumbers -UseSpecialCharacters
bFNC1D1K*ng37neaYYpT0J985+ZCaC47

# Adding upper case letters, numbers,special characters and some Cyrilic characters  to the pool,
#   while excluding '+', '*' and '#'
rndmstr 32 -UseUpperCase -UseNumbers -UseSpecialCharacters -IncludeCharacters "АБВГДЕЖЗИЙКЛМНОПРСТУ" -ExcludeCharacters "+*#"
eFlЛmOnmk7%Й1wj6ОLMtj%9@^В1tТ2bDw
```

# InvokeSomething (Alias `somethingsomething`) ![](InvokeSomething/logo.png)

This cmdlet lets the user very simply define a donothing script that prompts manual actions.
    The script can then easily be extended to automate certain actions.
    This module allows for some customisation

```ps1

    # Three manual steps
    somethingsomething "Open network"
    somethingsomething "Create the database"
    somethingsomething "Generate password"
    somethingsomething "Create login using the generated password"
    somethingsomething "Close network"


    # Partial Automation
    # Some steps are automated
    somethingsomething "Open network"
    somethingsomething "Create the database" "az sql db create -g test-rg -n test-db -s test-sql"
    somethingsomething "Generate password" "$Pass = 'abcdefghijklmn'.tochararray() | Sort-Object {Get-Random})"
    somethingsomething "Create login using the generated password" "Create-DB-Login -Username test -Password $Pass"
    somethingsomething "Create the database"

    # Semi-Automation
    # Each step is automated, but we user input is prompted to continue to the next
    somethingsomething "Open network" "az sql server update  --restrict-outbound-network-access false" 
    somethingsomething "Create the database" "az sql db create -g test-rg -n test-db -s test-sql" 
    somethingsomething "Generate password" "$Pass = 'abcdefghijklmn'.tochararray() | Sort-Object {Get-Random})"
    somethingsomething "Create login using the generated password" "Create-DB-Login -Username test -Password $Pass"
    somethingsomething "Close network" "az sql server update  --restrict-outbound-network-access false"
    
    # Luxury-Automation
    # Each step is automated and continues automatically,
    # "Creating the database" step is evaluated for a minute by a custom script
    #  to ensure success before continuing to the next
    somethingsomething "Open network" "az sql server update  --restrict-outbound-network-access false" -y
    somethingsomething "Create the database" "az sql db create -g test-rg -n test-db -s test-sql" `
        -Evaluate "az sql db show list --query name | Convert-FromJson |$_count>0 " -y
    somethingsomething "Generate password" "$Pass = 'abcdefghijklmn'.tochararray() | Sort-Object {Get-Random})" -y
    somethingsomething "Create login using the generated password" "Create-DB-Login -Username test -Password $Pass" -y
    somethingsomething "Close network" "az sql server update  --restrict-outbound-network-access false" -y

```