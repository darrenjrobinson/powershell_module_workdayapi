@{
RootModule = 'WorkdayApi.psm1'
ModuleVersion = '2.1.5'
GUID = 'bd4390dc-a8ad-4bce-8d69-f53ccf8e4163'
Author = 'Nathan Hartley & Darren J Robinson'
Copyright = '(c) 2019 . All rights reserved.'
Description = 'Provides a means to access the Workday SOAP API in a Powershell friendly manner.'
PowerShellVersion = '5.0'
FunctionsToExport = @(
        'ConvertFrom-WorkdayWorkerXml',
		'Export-WorkdayDocument',
        'Get-WorkdayToAdData',
        'Get-WorkdayReport',
        'Get-WorkdayWorker',
		'Get-WorkdayWorkerAdv'
        'Get-WorkdayWorkerByIdLookupTable',
        'Invoke-WorkdayRequest',
        'Remove-WorkdayConfiguration',
		'Set-WorkdayWorkerPhoto',
        'Get-WorkdayWorkerPhoto',
        'Get-WorkdayEndpoint',
        'Set-WorkdayCredential',
        'Set-WorkdayEndpoint',
        'Save-WorkdayConfiguration',
        'Get-WorkdayWorkerEmail',
		'Set-WorkdayWorkerEmail',
        'Update-WorkdayWorkerEmail',
        'Get-WorkdayWorkerDocument',
        'Set-WorkdayWorkerDocument',
        'Get-WorkdayWorkerNationalId',
        'Get-WorkdayWorkerOtherId',
        'Remove-WorkdayWorkerOtherId',
        'Set-WorkdayWorkerOtherId',
        'Update-WorkdayWorkerOtherId',
        'Get-WorkdayWorkerProvData',
        'Get-WorkdayWorkerMgmtData',
        'Get-WorkdayWorkerPhone',
		'Set-WorkdayWorkerPhone',
        'Update-WorkdayWorkerPhone',
        'Start-WorkdayIntegration',
        'Get-WorkdayIntegrationEvent',
        'Get-WorkdayDate'
	)
}

