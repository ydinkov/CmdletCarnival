Overview
This cmdlet lets the user very simply define a donothing script inspired by Dan Slimmon's blog post.

Prompts
The cmdlet lets a user create a single step in a donothing script. This step will simply prompt the user to take the described action and to confirm that it has been executed successfully.

Automation
The step can be extended at any time with a PowerShell expression to automate the action. The user will still be prompted to continue to the next action. Using the -y flag, then can skip the manual prompt.

Evaluation
For async tasks, the step can be extended with an -Evaluate parameter. This is an expression, will allow the step to evaluate whether it was successful or not. Using the -RetryAction flag, not only will the evaluation be retried, but also the action itself, making it into a functional Retry Policy.

Usage
Create a script file outlining the manual steps that need to be performed. Use the examples below as a guide
Pick any one step to automate by adding a PowerShell expression in the second parameter
For asynchronous steps, you can add a second expression after the -Evaluate parameter. This expression must return $true or $false and will evaluate if the step was successful or not
If you are confident about the execution of the step add a -y flag to skip the prompt and automatically execute the next step
Examples
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
