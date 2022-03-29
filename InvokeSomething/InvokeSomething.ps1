function Invoke-Something {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        SupportsShouldContinue=$true
    )]
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
        [switch] $ContinueOnFailure,

        [Parameter(HelpMessage="If the evaluation fails, then re-execute the action instead of only retrying the evaluation")]
        [switch] $RetryAction    
    )
    # Determine type
    $Type = if($null -eq $Expression){"*AUTOMATED*"}else {"*MANUAL*"}
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
        if(($Success -eq $false) -and  $ContinueOnFailure){return $Result}
        else{throw "Evaluation failure aborted script... 💀"}
    }

    # Continue or abort
    if ($PSCmdlet.ShouldContinue("Continue?")) {return $Result}
    else{throw "User aborted script... 💀"}
}