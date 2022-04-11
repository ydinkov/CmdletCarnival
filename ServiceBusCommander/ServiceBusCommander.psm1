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
        return "SharedAccessSignature sig=$UrlEncodedSignatureString&se=$Expiry&skn=$PolicyName&sr=$UrlEncodedEndpoint"
}

<#    
.SYNOPSIS
Sends a message to service bus queue
#>
function Send-QueueMessage
{
    param(
        [string]$ConnectionString,
        [string]$Body,
        [string]$QueueName = "",
        [string]$ContentType = "application/json",
        [int]$TokenValidFor = 3600    
    )
    $SASToken = Get-SasToken -ConnectionString $ConnectionString -EnityName $QueueName -TokenValidFor $TokenValidFor
    $Params = @{
        Uri = "https://$($Endpoint.Host)/$($QueueName)/messages"
        ContentType = "$($ContentType);charset=utf-8"
        Method = 'Post'
        Body = $Body
        Headers = @{
            'Authorization' = $SASToken
        }
    }
    Start-Sleep -Seconds 1
    Invoke-RestMethod @Params
}



