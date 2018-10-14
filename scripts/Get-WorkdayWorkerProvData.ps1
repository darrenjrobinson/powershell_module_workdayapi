function Get-WorkdayWorkerProvData {
<#
.SYNOPSIS
    Returns a Worker's Provisioning Data information.

.DESCRIPTION
    Returns a Worker's Provisioning Data information as custom Powershell objects.

.PARAMETER WorkerId
    The Worker's Id at Workday.

.PARAMETER WorkerType
    The type of ID that the WorkerId represents. Valid values
    are 'WID', 'Contingent_Worker_ID' and 'Employee_ID'.

.PARAMETER Human_ResourcesUri
    Human_Resources Endpoint Uri for the request. If not provided, the value
    stored with Set-WorkdayEndpoint -Endpoint Human_Resources is used.

.PARAMETER Username
    Username used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.PARAMETER Password
    Password used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.EXAMPLE
    
Get-WorkdayWorkerProvData -WorkerId 123

Provisioning_Group Status   Last_Changed
------------------ ------   ------------
Office 365 (email) Assigned 2017-05-01T04:23:27.578-07:00
Active Directory   Assigned 2017-05-01T04:30:30.233-07:00
            

#>

	[CmdletBinding(DefaultParametersetName='Search')]
    [OutputType([PSCustomObject])]
	param (
		[Parameter(Mandatory = $true,
            Position=0,
            ParameterSetName='Search')]
		[ValidatePattern ('^[a-fA-F0-9\-]{1,32}$')]
		[string]$WorkerId,
        [Parameter(ParameterSetName="Search")]
		[ValidateSet('WID', 'Contingent_Worker_ID', 'Employee_ID')]
		[string]$WorkerType = 'Employee_ID',
        [Parameter(ParameterSetName="Search")]
		[string]$Human_ResourcesUri,
        [Parameter(ParameterSetName="Search")]
		[string]$Username,
        [Parameter(ParameterSetName="Search")]
		[string]$Password,
        [Parameter(ParameterSetName="NoSearch")]
        [xml]$WorkerXml
	)

    if ([string]::IsNullOrWhiteSpace($Human_ResourcesUri)) { $Human_ResourcesUri = $WorkdayConfiguration.Endpoints['Human_Resources'] }

    if ($PsCmdlet.ParameterSetName -eq 'Search') {
        $response = Get-WorkdayWorker -WorkerId $WorkerId -WorkerType $WorkerType -IncludePersonal -Human_ResourcesUri $Human_ResourcesUri -Username:$Username -Password:$Password -ErrorAction Stop
        $WorkerXml = $response.Xml
    }

    if ($WorkerXml -eq $null) {
        Write-Warning 'Unable to get Other Id information, Worker not found.'
        return
    }

    $provTemplate = [pscustomobject][ordered]@{       
        Provisioning_Group = $null
        Status = $null
        Last_Changed = $null        
    }

    $WorkerXml.GetElementsByTagName('wd:Provisioning_Group_Assignment_Data') | ForEach-Object {
        $o = $provTemplate.PsObject.Copy()
        $o.Provisioning_Group = $_.Provisioning_Group
        $o.Status = $_.Status
        $o.Last_Changed = try{ Get-Date $_.Last_Changed -ErrorAction Stop } catch {}
        Write-Output $o
    }

}
