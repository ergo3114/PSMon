function Get-Monitoring{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = $env:COMPUTERNAME
    )

    BEGIN{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"

        Write-Verbose "Setting up variables"
        $results = @{}

        Write-Verbose "Getting function defaults"
        [xml]$xmlConfig = Get-Content $PSMon.ConfigFile
        $FreeSpaceConfig = $xmlConfig.Configuration.Function | Where-Object {$_.ID -eq "Get-PSMonFreeSpace"}
        $ProcessorConfig = $xmlConfig.Configuration.Function | Where-Object {$_.ID -eq "Get-PSMonProcessor"}
        $WorkingSetConfig = $xmlConfig.Configuration.Function | Where-Object {$_.ID -eq "Get-PSMonWorkingSet"}
    }

    PROCESS{
        Write-Verbose "Getting PSMon information"
        $FreeSpace = Get-FreeSpace -WarningThreshold $FreeSpaceConfig.WarningThreshold -ErrorThreshold $FreeSpaceConfig.ErrorThreshold
        $Processor = Get-Processor -WarningThreshold $ProcessorConfig.WarningThreshold -ErrorThreshold $ProcessorConfig.ErrorThreshold
        $WorkingSet = Get-WorkingSet -WarningThreshold $WorkingSetConfig.WarningThreshold -ErrorThreshold $WorkingSetConfig.ErrorThreshold

        $results.Add('FreeSpace',$FreeSpace)
        $results.Add('Processor',$Processor)
        $results.Add('WorkingSet',$WorkingSet)
        $results.Add('Collected',$(Get-Date))
    }

    END{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
        return $results
    }
}