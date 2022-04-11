Add-Type -AssemblyName System.Web
<#    
.SYNOPSIS
Retreives a service bus sastoken based on a provided connection string
#>
function Get-SasToken{
    param(
        [string]$ConnectionString,        
        [string]$EnityName = "",
        [int]$TokenValidFor = 3600    
    )
        $Pattern = 'Endpoint=(.+);SharedAccessKeyName=(.+);SharedAccessKey=(.+);EntityPath=(.+)'
        ([uri]$Endpoint),$PolicyName,$Key,$Enity = ($ConnectionString -replace $Pattern,'$1;$2;$3;$4') -split ';'    
        if($EnityName -ne "") {$Enity = $EnityName}
        $UrlEncodedEndpoint = [System.Web.HttpUtility]::UrlEncode($Endpoint.OriginalString)
        $Expiry = [DateTimeOffset]::Now.ToUnixTimeSeconds() + $TokenValidFor
        $RawSignatureString = "$UrlEncodedEndpoint`n$Expiry"    
        $HMAC = New-Object System.Security.Cryptography.HMACSHA256
        $HMAC.Key = [Text.Encoding]::ASCII.GetBytes($Key)
        $HashBytes = $HMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($RawSignatureString))
        $SignatureString = [Convert]::ToBase64String($HashBytes)
        $UrlEncodedSignatureString = [System.Web.HttpUtility]::UrlEncode($SignatureString)        
        return "SharedAccessSignature sig=$UrlEncodedSignatureString&se=$Expiry&skn=$PolicyName&sr=$UrlEncodedEndpoint", $Endpoint.TrimStart("sb://").TrimEnd("/")
}

function Send-Message
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True,ValuefromPipeline=$True)]
        [object]$Body,
        [Parameter(Mandatory=$True)]
        [string]$SASToken,
        [Parameter(Mandatory=$True,ValuefromPipeline=$True)]
        [object]$HostPath,
        [string]$QueueName = "",
        [string]$ContentType = "application/json"
    )
   
    if($ContentType -eq "application/json"){
        $MessageBody = ConvertTo-Json $Body
    }elseif ($ContentType -eq "application/xml") {
        $MessageBody = ConvertTo-Xml $Body
    }elseif ($ContentType -eq "application/csv") {
        $MessageBody = ConvertTo-Csv $Body
    }else{
        $MessageBody = Out-String -InputObject $Body;
    }
    
    $Params = @{
        Uri = "https://$($HostPath)/$($QueueName)/messages"
        ContentType = "$($ContentType);charset=utf-8"
        Method = 'Post'
        Body = $MessageBody
        Headers = @{
            'Authorization' = $SASToken
        }
    }
    Invoke-RestMethod @Params
}


<#    
.SYNOPSIS
Sends a message to service bus queue
#>
function Send-QueueMessage
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True,ValuefromPipeline=$True)]
        [object]$Body,
        [Parameter(Mandatory=$True)]
        [string]$ConnectionString,
        [string]$QueueName = "",
        [string]$ContentType = "application/json"
    )   
    
    $SASToken, $Endpoint= Get-SasToken -ConnectionString $ConnectionString -EnityName $QueueName -TokenValidFor $TokenValidFor
    Send-Message -Body $Body -SASToken $SASToken -QueueName $QueueName -ContentType $ContentType -HostPath $Endpoint
}


<#    
.SYNOPSIS
Sends many messages to the service bus queue
#>
function Send-QueueMessages
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True,ValuefromPipeline=$True)]
        [object[]]$Bodies,
        [Parameter(Mandatory=$True)]
        [string]$ConnectionString,
        [string]$QueueName = "",
        [string]$ContentType = "application/json",
        [int]$TokenValidFor = 3600,
        [double] $Delay = 0.0
    )
    $SASToken, $Endpoint = Get-SasToken -ConnectionString $ConnectionString -EnityName $QueueName -TokenValidFor $TokenValidFor
    $Bodies | ForEach-Object{
        Send-QueueMessage -Body $_ -SASToken $SASToken -QueueName $QueueName -ContentType $ContentType
        if($Delay -gt 0.0){ Start-Sleep -Seconds $Delay}    
    }
}


