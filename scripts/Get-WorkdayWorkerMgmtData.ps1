function Get-WorkdayWorkerMgmtData {
<#
.SYNOPSIS
    Returns a Worker's Management Heirarchy Data.

.DESCRIPTION
    Returns a Worker's Management Heirarchy Data as custom Powershell objects.

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
    
Get-WorkdayWorkerMgmtData -WorkerId 123

Manager_WID                      Manager_EmployeeID Manager_DisplayName
-----------                      ------------------ -------------------
1082dd20469510feea15e972925a949e 861426             Bob Jane         
1082dd20469510feea15e972925a949e 861426             Bob Jane         
1082dd20469510feea4b229da03631bc 291437             Les Smith       
1082dd20469510feea4fd9f697f96463 421019             Jan Wilson         
1082dd20469510feea5b3113bb0587be 423506             Nick O'Dwyer  
1082dd20469510feeab2c2e4c80c9044 551693             Pete Jackson             

. NOTE: The Top of the Org reports to themself
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
        $response = Get-WorkdayWorkerAdv -WorkerId $WorkerId -WorkerType $WorkerType -IncludeWork -Human_ResourcesUri $Human_ResourcesUri -Username:$Username -Password:$Password -ErrorAction Stop
        $WorkerXml = $response.Xml
    }

    if ($WorkerXml -eq $null) {
        Write-Warning 'Unable to get Other Id information, Worker not found.'
        return
    }

    $mgmtTemplate = [pscustomobject][ordered]@{       
        Manager_WID = $null
        Manager_EmployeeID = $null
        Manager_DisplayName = $null        
    }

    $WorkerXml.Worker.Worker_Data.Management_Chain_Data.Worker_Supervisory_Management_Chain_Data.Management_Chain_Data.Manager | ForEach-Object {
        $o = $mgmtTemplate.PsObject.Copy()
        $o.Manager_WID = $_.Worker_Reference.ID | Where-Object {$_.type -eq 'WID'} | Select-Object -ExpandProperty '#text' -Unique 
        $o.Manager_EmployeeID = $_.Worker_Reference.ID | Where-Object {$_.type -eq 'Employee_ID'} | Select-Object -ExpandProperty '#text'
        $o.Manager_DisplayName = $_.Worker_Descriptor
        Write-Output $o         
    }
}
