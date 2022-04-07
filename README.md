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
