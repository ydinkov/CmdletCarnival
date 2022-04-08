    <#    
    .SYNOPSIS
    A monimal donothing-script framework

    .DESCRIPTION
    This cmdlet lets the user very simply define a donothing script that prompts manual actions.
    The script can then easily be extended to automate certain actions.
    This module allows for some customisation

    .EXAMPLE
    # Three manual steps
    somethingsomething "Open network"
    somethingsomething "Create the database"
    somethingsomething "Generate password"
    somethingsomething "Create login using the generated password"
    somethingsomething "Close network"

    .EXAMPLE
    # Partial Automation
    # Some steps are automated
    somethingsomething "Open network"
    somethingsomething "Create the database" "az sql db create -g test-rg -n test-db -s test-sql"
    somethingsomething "Generate password" "$Pass = 'abcdefghijklmn'.tochararray() | Sort-Object {Get-Random})"
    somethingsomething "Create login using the generated password" "Create-DB-Login -Username test -Password $Pass"
    somethingsomething "Create the database"

    .EXAMPLE
    # Semi-Automation
    # Each step is automated, but we user input is prompted to continue to the next
    somethingsomething "Open network" "az sql server update  --restrict-outbound-network-access false" 
    somethingsomething "Create the database" "az sql db create -g test-rg -n test-db -s test-sql" 
    somethingsomething "Generate password" "$Pass = 'abcdefghijklmn'.tochararray() | Sort-Object {Get-Random})"
    somethingsomething "Create login using the generated password" "Create-DB-Login -Username test -Password $Pass"
    somethingsomething "Close network" "az sql server update  --restrict-outbound-network-access false"
    
    .EXAMPLE
    # Luxury-Automation
    # Each step is automated and continues automatically,
    # "Creating the database" step is evaluated for a minute by a custom script to ensure success before continuing to the next
    somethingsomething "Open network" "az sql server update  --restrict-outbound-network-access false" -y
    somethingsomething "Create the database" "az sql db create -g test-rg -n test-db -s test-sql" -Evaluate "az sql db show list --query name | Convert-FromJson |$_count>0 " -y
    somethingsomething "Generate password" "$Pass = 'abcdefghijklmn'.tochararray() | Sort-Object {Get-Random})" -y
    somethingsomething "Create login using the generated password" "Create-DB-Login -Username test -Password $Pass" -y
    somethingsomething "Close network" "az sql server update  --restrict-outbound-network-access false" -y

    #>
function Invoke-Something {
    [CmdletBinding(
        SupportsShouldProcess=$true       
    )]
    [Alias('somethingsomething')]
    param(
        [Parameter(
            Mandatory=$true,
            Position=0,
            HelpMessage="This message describes the action that the user should take or that will be automated"
            )]
        [string] $Message,

        [Parameter(
            Position=1,
            HelpMessage="Expression string that will be invoked with 'Invoke-Expression' to automate the task ")]
        [string] $Expression,

        [Parameter(HelpMessage="Expression string that will be invoked to evaluate wether the required state has been reached. Expression must resolve to `$true or `$false. If no evaluation is provided, the script will always succeed")]
        [string] $Evaluate,
        
        [Parameter(HelpMessage="Number of evaluations that will be performed until step fails")]
        [int] $MaxEvaluations = 60,
        
        [Parameter(HelpMessage="Time between evaluations")]
        [double] $Inteval = 1.0,

        [Parameter(HelpMessage="Continue to the next step if this step fails")]
        [switch] $ContinueOnFailure,

        [Parameter(HelpMessage="If the evaluation fails, then re-execute the action instead of only retrying the evaluation")]
        [switch] $RetryAction,    
        
        [Parameter(HelpMessage="If disabled, will not clear the screen after this step. Default: true")]
        [switch] $Clear=$true
    )
    # Determine type
    $Type = if(($null -eq $Expression) -or ("" -eq -$Expression)){"*MANUAL*"}else {"*AUTOMATED*"}
    Write-Host "################################################################################################"
    Write-Host $Type -ForeGroundColor Yellow
    Write-Host Message: $Message -BackGroundColor White -ForeGroundColor Black
    
    # Execute expression if able
    $Result = $null
    if(($null -ne $Expression) -and ($Expression -ne "")){        
        if ($PSCmdlet.ShouldProcess($Expression, "Are you sure you want to execute this query?")) {
            $Result = Invoke-Expression -Command $Expression
        }
    }
    # Evaluate results
    if(($Evaluate -ne "") -and ($Evaluate -ne $null)){    
        $Success = $false
        $Retries = 0
        while(($Success -ne $true) -and ($Retries -le $MaxEvaluations)){
            if($RetryAction) {$Result = Invoke-Expression -Command $Expression}
            $Success = Invoke-Expression -Command $Evaluate
            if($Success ){
                Write-Host $Evaluate -ForeGroundColor Cyan
                Write-Host PASSED! ✅ -ForeGroundColor Green
            }
            else{v
                Write-Host $Evaluate -ForeGroundColor Cyan
                Write-Host "Pending...(" $Retries"/" $MaxEvaluations ") ⌛" -ForeGroundColor DarkGray
                $Retries = $Retries + 1
                Start-Sleep -Seconds $Inteval
            }
        }
        if(($Success -eq $false) -and  $ContinueOnFailure){return}
        else{
            Write-Host "Evaluation failure aborted script... 💀" -BackgroundColor Red -ForegroundColor Black
            exit
        }
    }

    # Continue or abort
    if ($PSCmdlet.ShouldContinue("Move on to the next step?","")) {return}
    else{
        Write-Host "User aborted script... 💀"  -ForegroundColor Red
        exit
    }
    Clear-Host
}
