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

#Send simple plaintext message
Send-QueueMessage -ConnectionString <ConnectionString> -Body "Hello"

#Send single json Message
Send-QueueMessage -ConnectionString <ConnectionString> -Body "{'MessageId':111,'Message':'bar'}"  -ContentType 'application/json'

#Send records from csv file as individual json messaegs
Import-Csv Customers.csv | Send-QueueMessages -ConnectionString <ConnectionString>

#XML variant
Import-Csv Customers.csv | Send-QueueMessages -ConnectionString <ConnectionString> -ContentType 'application/xml'


```


## Implemented

### Queues:
- Send-QueueMessage
- Send-QueueMessages
- TODO: Peek-QueueMessages
- TODO: Receive-QueueMessages

### Topics:
- TODO: Send-TopiceMessage
- TODO: Send-TopiceMessages
- TODO: Peek-TopicMessages
- TODO: Receive-TopicMessages

### Management
- Get-SasToken
- TODO: Create-Queue
- TODO: Create-Subscription
- TODO: Create-Topic
