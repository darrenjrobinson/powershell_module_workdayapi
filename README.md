# Workday SOAP API Powershell Script Module #


## Description ##
Provides simple methods for accessing the Workday SOAP API.

This simple Powershell Module has been written to fulfill my employer's Workday automation needs. I see this as a prototype, while I experiment with the best way to expose the complexities of the Workday API in a Powershell-y way. Thinking that the community might find it helpful and may even wish to comment or contribute, I have hosted the source on GitHub  (https://github.com/treestryder/powershell_module_workdayapi).


## Features ##

* Easy command-line use, after setting default configuration options and securely saving them to the current user's profile.
* Get Worker information for one or all workers.
* Get / Set / Update Worker email.
* Get / Set / Update Worker phone.
* Upload Worker Photos.
* Upload Worker Documents.
* Run reports.
* Trigger Integrations and retreive their status.
* Submit arbitrary API calls.
* A sample script to push A.D. changes to Workday (samples/Push_AD_to_Workday.ps1).

## Customisations by Darren J Robinson ###

* Get additional Worker details specific to our implementation using the Get-WorkdayWorkerAdv cmdlet
* Get Worker Management Data - Manager Heirarchy, Worker Type Reference, Supervisory Org, Job Profile Name, Job Profile ID
* Get Worker Location Data - Work City, Work State, Work Country, Workspace, Location
* Get Worker Provisioning Data - Provisioning Group flags
* Delta changes 

    Examples Employee
    ```
    Get-WorkdayWorkerADV -WorkerType Employee_ID -WorkerId 123456 -IncludeWork -IncludePersonal -IncludeDocuments
    Get-WorkdayWorkerProvData -WorkerType Employee_ID -WorkerId 123456
    Get-WorkdayWorkerMgmtData -WorkerType Employee_ID -WorkerId 123456
    Get-WorkdayWorkerOtherId -WorkerType Employee_ID -WorkerId 123456
    ```

    Examples Contingent
    ```
    Get-WorkdayWorkerADV -WorkerType Contingent_Worker_ID -WorkerId 456789 -IncludeWork -IncludePersonal -IncludeDocuments
    Get-WorkdayWorkerProvData -WorkerType Contingent_Worker_ID -WorkerId 456789
    Get-WorkdayWorkerMgmtData -WorkerType Contingent_Worker_ID -WorkerId 456789
    Get-WorkdayWorkerOtherId -WorkerType Contingent_Worker_ID -WorkerId 456789
    ```

    Example Delta Sync
    ```
    Get-WorkdayWorkerAdv -WorkerType WID -FromDate 2019-10-16T11:44:39.6265792+11:00 -ToDate 2019-10-18T12:00:01.6232171+11:00
    ```

## Examples ##

    Set-WorkdayCredential
    Set-WorkdayEndpoint -Endpoint Staffing        -Uri 'https://SERVICE.workday.com/ccx/service/TENANT/Staffing/v26.0'
    Set-WorkdayEndpoint -Endpoint Human_Resources -Uri 'https://SERVICE.workday.com/ccx/service/TENANT/Human_Resources/v26.0'
    Set-WorkdayEndpoint -Endpoint Integrations    -Uri 'https://SERVICE.workday.com/ccx/service/TENANT/Integrations/v26.0'
    Save-WorkdayConfiguration

    Set-WorkdayWorkerPhone -WorkerId 123 -WorkerType Employee_ID -Number '+1 (234) 987-6543'

    Get-WorkdayWorkerPhone -WorkerId 123 -WorkerType Employee_ID | Format-Table

    UsageType DeviceType Number           Extension Primary Public
    --------- ---------- ------           --------- ------- ------
    Home      Landline   1 (234) 567-8910             False  False
    Work      Landline   1 (234) 987-6543              True  False
    

    $response = Invoke-WorkdayRequest -Request '<bsvc:Server_Timestamp_Get xmlns:bsvc="urn:com.workday/bsvc" />' -Uri https://SERVICE.workday.com/ccx/service/TENANT/Human_Resources/v26.0
    $response.Xml.Server_TimeStamp

    wd                   version Server_Timestamp_Data        
    --                   ------- ---------------------        
    urn:com.workday/bsvc v25.1   2015-12-02T12:18:30.841-08:00


    Get-Command -Module WorkdayApi | sort Name | Get-Help | Format-Table Name, Synopsis -AutoSize

    Name                             Synopsis
    ----                             --------
    ConvertFrom-WorkdayWorkerXml     Converts Workday Worker XML into a custom object.
    Export-WorkdayDocument           Exports Workday Documents.
    Get-WorkdayDate                  Gets the current time and date from Workday.
    Get-WorkdayEndpoint              Gets the default Uri value for all or a particular Endpoint.
    Get-WorkdayIntegrationEvent      Retrieves the status of a Workday Integration.
    Get-WorkdayReport                Returns the XML result from any Workday report, based on its URI.
    Get-WorkdayToAdData              Converts Get-WorkdayWorker output into "INT011 WD to AD - DT" format.
    Get-WorkdayWorker                Gets Worker information as Workday XML.
    Get-WorkdayWorkerAdv             Gets Worker information as Workday XML.
    Get-WorkdayWorkerByIdLookupTable Returns a hashtable of Worker Type and IDs, indexed by ID.
    Get-WorkdayWorkerDocument        Gets Workday Worker Documents.
    Get-WorkdayWorkerEmail           Returns a Worker's email addresses.
    Get-WorkdayWorkerMgmtData        Returns a Worker's Management Heirarchy Data.
    Get-WorkdayWorkerNationalId      Returns a Worker's National Id information.
    Get-WorkdayWorkerOtherId         Returns a Worker's Id information.
    Get-WorkdayWorkerPhone           Returns a Worker's phone numbers.
    Get-WorkdayWorkerPhoto           Get Worker's photo from Workday.
    Get-WorkdayWorkerProvData        Returns a Worker's Provisioning Data information.
    Invoke-WorkdayRequest            Sends XML requests to Workday API, with proper authentication and receives XML response.
    Remove-WorkdayConfiguration      Removes Workday configuration file from the current user's Profile.
    Remove-WorkdayWorkerOtherId      Sets the Custom_ID_Type_ID "Badge_ID".
    Save-WorkdayConfiguration        Saves default Workday configuration to a file in the current users Profile.
    Set-WorkdayCredential            Sets the default Workday API credentials.
    Set-WorkdayEndpoint              Sets the default Uri value for a particular Endpoint.
    Set-WorkdayWorkerDocument        Uploads a document to a Worker's records in Workday.
    Set-WorkdayWorkerEmail           Sets a Worker's email in Workday.
    Set-WorkdayWorkerOtherId         Sets the Custom_ID_Type_ID "Badge_ID".
    Set-WorkdayWorkerPhone           Sets a Worker's phone number in Workday.
    Set-WorkdayWorkerPhoto           Uploads an image file to Workday and set it as a Worker's photo.
    Start-WorkdayIntegration         Starts a Workday Integration.
    Update-WorkdayWorkerEmail        Updates a Worker's email in Workday, only if it is different.
    Update-WorkdayWorkerOtherId      Updates a Worker's phone number in Workday, only if it is different.
    Update-WorkdayWorkerPhone        Updates a Worker's phone number in Workday, only if it is different.              

## Installation ##

The only dependency is Powershell version 5.

To install...

* Download the files.
* Execute the script Install-WorkdayModule.ps1

## Fine Print ##
Please use with caution. This module could cause baldness, could warp time and space, could kill your puppy or, could do nothing at all. I am sharing what I am using as a starting point for a community developed solution.

Any and all contributions are more than welcome and appreciated. 
