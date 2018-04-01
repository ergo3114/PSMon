function Init{
    [cmdletbinding(SupportsShouldProcess)]
    Param()

    BEGIN{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"

        $stringConfig = @"
<?xml version="1.0"?>
<Configuration>
    <Function ID="Get-PSMonFreeSpace">
        <WarningThreshold>25</WarningThreshold>
        <ErrorThreshold>10</ErrorThreshold>
    </Function>
    <Function ID="Get-PSMonProcessor">
        <WarningThreshold>80</WarningThreshold>
        <ErrorThreshold>90</ErrorThreshold>
    </Function>
    <Function ID="Get-PSMonWorkingSet">
        <WarningThreshold>10</WarningThreshold>
        <ErrorThreshold>20</ErrorThreshold>
    </Function>
</Configuration>
"@
    }

    PROCESS{
        Write-Verbose "Checking if configuration file exists"
        if(!(Test-Path $PSMon.ConfigFile)){
            Write-Verbose "Recreating configuration file"
            if ($pscmdlet.ShouldProcess($PSMon.ConfigFile, "Recreate Config File")){
                New-Item -Path $PSMon.ConfigFile -ItemType File -Value $stringConfig
            }
        }
    }

    END{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
    }
}