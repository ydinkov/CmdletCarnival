# ServiceBusCommander ![](logo.png)
This cmdlet lets the user interact with Azure Service bus namespaces.

The code for generating a sas token is from [Emanuel Palm's excellent blog](https://pipe.how/send-servicebusmessage/)

## Installation

The modules requires the following .NET classes:
- System.Web.HttpUtility
- DateTimeOffset
- Text.Encoding
- Convert

Download it from [Powershell Gallery](https://www.powershellgallery.com/packages/ServiceBusCommander/)
or  run:
```ps1
Install-Module -Name ServiceBusCommander
```

## Send-QueueMessage

This commands seds a raw message to a target service bus queue

```ps1
#Send single message
Send-QueueMessage -ConnectionString <servicebus queue connectionString> -ContentType json -Body "{'MessageId':111,'Message':'bar'}"

#Send from csv file
Import-Csv Customers.csv | ForEach-Object { 
    $Body = ConvertTo-Json $_
    Send-QueueMessage -ConnectionString $ConnectionString -Body $Body
}

```


## Implemented

### Queues:
- Send-QueueMessage
- TODO: Peek-QueueMessages
- TODO: Receive-QueueMessages

### Topics:
- TODO: Send-TopiceMessage
- TODO: Peek-TopicMessages
- TODO: Receive-TopicMessages

### Management
- Get-SasToken
- TODO: Create-Queue
- TODO: Create-Subscription
- TODO: Create-Topic
