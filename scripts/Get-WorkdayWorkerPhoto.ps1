function Get-WorkdayWorkerPhoto {
<#
.SYNOPSIS
    Get Worker's photo from Workday.

.DESCRIPTION
    Downloads a Workers Photo from Workday as a JPG image file

.PARAMETER WorkerId
    The Worker's Id at Workday.

.PARAMETER WorkerType
    The type of ID that the WorkerId represents. Valid values
    are 'WID', 'Contingent_Worker_ID' and 'Employee_ID'.

.PARAMETER Path
    The Path to the image file to upload. e.g 'c:\workday\profilephotos'

.PARAMETER Human_ResourcesUri
    Human_Resources Endpoint Uri for the request. If not provided, the value
    stored with Set-WorkdayEndpoint -Endpoint Human_Resources is used.

.PARAMETER Username
    Username used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.PARAMETER Password
    Password used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.PARAMETER PhotoPath
    Output Path for the Photo. e.g "c:\workday\userphotos"

.EXAMPLE
    
Get-WorkdayWorkerPhoto -WorkerId 123 -PhotoPath 'c:\workday\photos'


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
        [string]$PhotoPath,
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
        $response = Get-WorkdayWorkerAdv -WorkerId $WorkerId -WorkerType $WorkerType -includePhoto -Human_ResourcesUri $Human_ResourcesUri -Username:$Username -Password:$Password -ErrorAction Stop
        $WorkerXml = $response.Xml
    }
    
    if ($PhotoPath -eq $null) {
        Write-Warning 'Unable to output Photo. Use -PhotoPath to specify output location.'
        break        
    } 

    if ($WorkerXml -eq $null) {
        Write-Warning 'Unable to get Photo information, Worker not found.'
        return
    }

    $binaryImage = $null 
    $ImageFilename = $null 
    $fileLength = $null 
    $fileExt = $null 
    if($WorkerXml.Worker.Worker_Data.Photo_Data.Image){ 
        [string]$binaryImage = $WorkerXml.Worker.Worker_Data.Photo_Data.Image
        $ImageFilename = $WorkerXML.Worker.Worker_Data.Photo_Data.Filename
        $fileExt = $ImageFilename.Substring($ImageFilename.IndexOf("."),$ImageFilename.Length-($ImageFilename.IndexOf(".")))        
        $bytes = [Convert]::FromBase64String($binaryImage)
        [IO.File]::WriteAllBytes("$($PhotoPath)\$($WorkerId)$($fileExt)", $bytes)
    } else {
        Write-Warning 'User Photo not found in Workday'
    }
}


