function ConvertFrom-WorkdayWorkerXml {
    <#
    .Synopsis
       Converts Workday Worker XML into a custom object.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [xml[]]$Xml
    )
    
    Begin {
        $WorkerObjectTemplate = [pscustomobject][ordered]@{
            WorkerWid           = $null
            WorkerDescriptor    = $null
            PreferredName       = $null
            FirstName           = $null
            LastName            = $null
            WorkerType          = $null
            WorkerId            = $null
            UserId              = $null            
            NationalId          = $null
            OtherId             = $null
            ProvisioningGroup   = $null 
            Phone               = $null
            Email               = $null
            BusinessTitle       = $null
            JobProfileName      = $null
            JobProfileID        = $null 
            Employer            = $null
            Location            = $null
            WorkSpace           = $null
            WorkerTypeReference = $null
            Manager             = $null
            MgmtData            = $null
            HireDate            = $null
            StartDate           = $null
            Active              = $null
            EndDate             = $null
            Supplier            = $null
            WorkCity            = $null
            WorkState           = $null
            WorkCountry         = $null
            XML                 = $null
        }
        $WorkerObjectTemplate.PsObject.TypeNames.Insert(0, "Workday.Worker")
    }
    
    Process {
        foreach ($elements in $Xml) {
            foreach ($x in $elements.SelectNodes('//wd:Worker', $NM)) {
                $o = $WorkerObjectTemplate.PsObject.Copy()
                $referenceId = $x.Worker_Reference.ID | Where-Object { $_.type -ne 'WID' }
                $o.WorkerWid = $x.Worker_Reference.ID | Where-Object { $_.type -eq 'WID' } | Select-Object -ExpandProperty '#text'
                $o.WorkerDescriptor = $x.Worker_Descriptor
                $o.PreferredName = $x.Worker_Data.Personal_Data.Name_Data.Preferred_Name_Data.Name_Detail_Data.Formatted_Name
                $o.FirstName = $x.Worker_Data.Personal_Data.Name_Data.Preferred_Name_Data.Name_Detail_Data.First_Name
                $o.LastName = $x.Worker_Data.Personal_Data.Name_Data.Preferred_Name_Data.Name_Detail_Data.Last_Name
                $o.WorkerType = $referenceId.type
                $o.WorkerId = $referenceId.'#text'
                $o.HireDate = $x.GetElementsByTagName('wd:Hire_Date').'#text'
                $o.StartDate = $x.GetElementsByTagName('wd:First_Day_of_Work').'#text'
                $o.Active = $x.GetElementsByTagName('wd:Active').'#text'
                $o.EndDate = $x.GetElementsByTagName('wd:Termination_Date').'#text'
    
                try {
                    if ($x.GetElementsByTagName('wd:Supplier_Reference').ID.'#text'[1]) {
                        $o.Supplier = $x.GetElementsByTagName('wd:Supplier_Reference').ID.'#text'[1] 
                    }
                }
                catch { 
                    #ignore 
                }
                $o.XML = [XML]$x.OuterXml
    
                $o.Phone = @(Get-WorkdayWorkerPhone -WorkerXml $x.OuterXml)
                $o.Email = @(Get-WorkdayWorkerEmail -WorkerXml $x.OuterXml)
                $o.NationalId = @(Get-WorkdayWorkerNationalId -WorkerXml $x.OuterXml)
                $o.OtherId = @(Get-WorkdayWorkerOtherId -WorkerXml $x.OuterXml)
                $o.ProvisioningGroup = @(Get-WorkdayWorkerProvData -WorkerXml $x.OuterXml)
                $o.MgmtData = @(Get-WorkdayWorkerMgmtData -WorkerXml $x.OuterXml)
                $o.UserId = $x.Worker_Data.User_ID
    
                $workerJobData = $x.SelectSingleNode('//wd:Worker_Job_Data', $NM)
                if ($workerJobData -ne $null) {
                    $o.BusinessTitle = $workerJobData.Position_Data.Business_Title
                    $o.JobProfileName = $workerJobData.Position_Data.Job_Profile_Summary_Data.Job_Profile_Name
                    $o.JobProfileID = $workerJobData.SelectNodes('wd:Position_Data/wd:Job_Profile_Summary_Data/wd:Job_Profile_Reference/wd:ID[@wd:type="Job_Profile_ID"]', $NM).InnerText                    
                    $o.Location = $workerJobData.SelectNodes('wd:Position_Data/wd:Business_Site_Summary_Data/wd:Location_Reference/wd:ID[@wd:type="Location_ID"]', $NM).InnerText
                    $o.WorkSpace = $workerJobData.SelectNodes('wd:Position_Data/wd:Work_Space__Reference/wd:ID[@wd:type="Location_ID"]', $NM).InnerText
                    $o.WorkerTypeReference = $workerJobData.SelectNodes('wd:Position_Data/wd:Worker_Type_Reference/wd:ID[@wd:type="Employee_Type_ID"]', $NM).InnerText
                    $o.WorkCity = $workerJobData.SelectNodes('wd:Position_Data/wd:Business_Site_Summary_Data/wd:Address_Data/wd:Municipality', $NM).InnerText                    
                    $o.WorkState = $workerJobData.SelectNodes('wd:Position_Data/wd:Business_Site_Summary_Data/wd:Address_Data/wd:Country_Region_Reference/wd:ID[@wd:type="ISO_3166-2_Code"]', $NM).InnerText
                    $o.WorkCountry = $workerJobData.SelectNodes('wd:Position_Data/wd:Business_Site_Summary_Data/wd:Address_Data/wd:Country_Reference/wd:ID[@wd:type="ISO_3166-1_Alpha-2_Code"]', $NM).InnerText                    
                    $o.Manager = $workerJobData.Position_Data.Manager_as_of_last_detected_manager_change_Reference.ID |
                    Where-Object { $_.type -ne 'WID' } |
                    Select-Object @{Name = 'WorkerType'; Expression = { $_.type } }, @{Name = 'WorkerID'; Expression = { $_.'#text' } }
                }
    
                Write-Output $o
    
                if ($global:photo -and $global:PhotoPathOut) {
                    Get-WorkdayWorkerPhoto -WorkerId $referenceId.'#text' -WorkerType $referenceId.type -PhotoPath $global:PhotoPathOut                                       
                }
            }
        }
    }
}