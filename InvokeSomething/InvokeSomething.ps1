function Invoke-Something {
    [CmdletBinding()]
    [Alias('somethingsomething')]
    param(
    [Parameter(
        Mandatory=$true,
        HelpMessage="This message describes the action that the user should take or that will be automated"
        )]
    [string] $Message,

    [Parameter(HelpMessage="Expression string that will be invoked with 'Invoke-Expression' to automate the task ")]
    [string] $Expression,

    [Parameter(HelpMessage="Expression string that will be invoked to evaluate wether the required state has been reached. Expression must resolve to `$true or `$false. If no evaluation is provided, the script will always succeed")]
    [string] $Evaluate,
    
    [Parameter(HelpMessage="Number of evaluations that will be performed until step fails")]
    [int] $MaxEvaluations = 60,
    
    [Parameter(HelpMessage="Time between evaluations")]
    [double] $Inteval = 1.0,

    [Parameter(HelpMessage="Continue to the next step if this step fails")]
    [switch] $ContinueOnFailure, #TODO

    [Parameter(HelpMessage="If the evaluation fails, then re-execute the action instead of only retrying the evaluation")]
    [switch] $RetryAction #TODO
    
    )


    $Type = if($null -eq $Expression){"*AUTOMATED*"}else {"*MANUAL*"}
    Write-Host $Type -ForeGroundColor Yellow
    Write-Host Message: $Message -BackGroundColor White -ForeGroundColor Black
    if(($null -ne $Expression) -and ($Expression -ne "")){        
        Write-Host Execute? -NoNewLine
        Write-Host `t`"$Expression`" -ForeGroundColor Cyan
        Read-Host
        Invoke-Expression -Command $Expression
    }

    if(($WaitUntil -ne "") -and ($WaitUntil -ne $null)){    
        $Success = $false
        $Retries = 0
        while(($Success -ne $true) -and ($Retries -le $MaxEvaluations)){
            $Success = Invoke-Expression -Command $WaitUntil
            if($Success ){
                Write-Host $WaitUntil -ForeGroundColor Cyan
                Write-Host PASSED! ✅ -ForeGroundColor Green
            }
            else{v
                Write-Host $WaitUntil -ForeGroundColor Cyan
                Write-Host "Pending...(" $Retries"/" $MaxEvaluations ") ⌛" -ForeGroundColor DarkGray
                $Retries = $Retries + 1
                Start-Sleep -Seconds $Inteval

            }
        }
    }
    Read-Host "Continue?"
}